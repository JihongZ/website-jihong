// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let suppl = it.at("supplement", default: none)
  if suppl == none or suppl == auto {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let target = query(it.target, loc).first()
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#show: doc => article(
  title: [ESRM 6990V: Advanced Seminar - Intro to R],
  authors: (
    ( name: [Jihong Zhang],
      affiliation: [],
      email: [] ),
    ),
  date: [2025-01-13],
  sectionnumbering: "1.1.a",
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)


#align(center)[
#box(image("images/clipboard-4222849525.png", width: 400))
]
= General Information
<general-information>

#horizontalrule

- Course Code: ESRM 6990V
- Credits: 3 CH
- Course time and location: Wed 17:00-19:45; GRAD 210
- Instructor: Jihong Zhang, Dr.
- Contact Information: #link("mailto:jzhang@uark.edu")[jzhang\@uark.edu]
- Personal Website: #link("http://jihongzhang.org")
- Office Location: GRAD 133B
- Office Hours: Tu 1:30-4:30PM
- Office Phone +1 479-575-5235
- Semester: Spring 2025

== Course Objectives, Materials, and Pre-Requisites:
<course-objectives-materials-and-pre-requisites>
The online syllabus will always contain the most up-to-date information. This course provides a comprehensive introduction to R programming with an emphasis on data analysis and visualization in environmental and natural resource management contexts. Students will learn through hands-on coding exercises, practical examples, and real-world applications.

This course has three main objectives:

+ #strong[Develop proficiency in R programming fundamentals]
  - Master R syntax, data structures, and basic operations
  - Learn to write efficient, reproducible code
  - Understand R’s package ecosystem and workspace management
+ #strong[Build practical data analysis skills]
  - Import, clean, and manipulate various data formats
  - Create publication-quality visualizations using ggplot2
  - Perform basic statistical analyses in R
  - Apply R to environmental and natural resource datasets
+ #strong[Establish foundation for advanced R applications]
  - Develop problem-solving strategies for programming challenges
  - Learn best practices for documentation and version control
  - Prepare for advanced R applications in environmental science

Class time will be devoted to interactive lectures, live coding demonstrations, and hands-on exercises. All lecture materials, including R scripts and datasets, will be available in .html and .R formats on the course website prior to each class. Weekly coding assignments will reinforce concepts covered in lectures. While recorded lectures will be available upon request, active participation in class is essential for developing programming skills.

- Required software:
  - R (latest stable version)
  - RStudio Desktop
  - Git (for version control)

No prior programming experience is required, but basic statistical knowledge and familiarity with data analysis concepts is recommended. Students should have access to a laptop computer capable of running R and RStudio.

== How to Be Successful in This Class
<how-to-be-successful-in-this-class>
- Come to class ready to learn and come with your laptop;
- Complete in-class exercises;
- If you become confused or don’t fully grasp a concept, ask for help from your instructor
- Know what is going on: keep up with email, course announcements, and the course schedule.
- Try to apply the information to your area of interest — if you have a cool research idea, come talk to me!

== Software
<software>
- #link("https://cran.r-project.org/")[R and R packages]
- #link("https://quarto.org/")[Quarto]
- #link("https://posit.co/download/rstudio-desktop/")[RStudio (Posit)]

= Course Materials
<course-materials>
== Web Books
+ #link("https://rafalab.dfci.harvard.edu/dsbook-part-1/")[Introduction to Data Science Part I - Data Wrangling and Visualization with R] by #emph[Rafael A. Irizarry]
+ #link("http://rafalab.dfci.harvard.edu/dsbook-part-2/")[Introduction to Data Science Part II - Statistics and Prediction Algorithms Through Case Studies] by #emph[Rafael A. Irizarry]
+ #link("https://r4ds.hadley.nz/")[R for Data Science] - Visualize, Model, Transform, Tidy and Import Data by #emph[Hadley Wickham] & #emph[Garret Grolemund]
+ #link("https://yards.albert-rapp.de/")[Yet Again: R + Data Science];by #emph[Albert Rapp]
+ #link("https://happygitwithr.com/")[Happy Git and GitHub for the useR] by #link("https://github.com/jennybc/happy-git-with-r")[#emph[Jennifer Bryan];]
+ #link("https://bookdown.org/rdpeng/rprogdatascience/")[R Programming for Data Science] by #emph[Roger D. Peng]

== R Community
+ #link("https://rweekly.org/")[RWeekly.org]

== Publications
== Outline
<outline>
This 17-week course is structured in four main modules that progressively build students’ R programming and data science skills:

+ #strong[Foundations of R Programming] (Weeks 1-3)
  - Introduction to R basics and environment
  - Core programming concepts
  - Fundamental R syntax and operations
+ #strong[Data Management and Processing] (Weeks 4-8)
  - Academic reporting with R projects and Quarto markdown
  - Data manipulation using tidyverse ecosystem:
    - Data summarization
    - Data cleaning
    - Data transformation
  - Data importing techniques
+ #strong[Data Visualization] (Weeks 9-11)
  - Comprehensive coverage of ggplot2:
    - Basic plotting principles
    - Advanced visualization techniques
    - Complex visualization applications
+ #strong[Professional Tools and Project Management] (Weeks 13-17)
  - Command-line operations (Terminal/PowerShell)
  - Version control with Git and GitHub
  - Final project implementation and presentation

- Key Features:
  - Hands-on learning approach with weekly lectures
  - Focus on tidyverse ecosystem for modern R programming
  - Integration of professional tools (Quarto, Git)
  - Culminates in a final project
  - Two scheduled breaks: MLK Holiday (Week 2) and Spring Break (Week 12)

Learning Progression: The course is designed to progress from basic R fundamentals to advanced data manipulation and visualization techniques, concluding with professional development tools and a practical final project that synthesizes all learned concepts.

== Why ITDS?
<why-itds>
This book is free and comprehensive for a broad R tasks of data analysis. For example, the book covers R programming (#strong[basics of R];), data wrangling with #strong[dplyr];, data visualization with #strong[ggplot2];, file organization with #strong[Unix/Linux shell];, version control with #strong[Git/Github];, and reproducible document preparation with #strong[#emph[Quarto];] and #strong[#emph[knitr];];.

= Final Project Requirements
<final-project-requirements>
== Overview
<overview>
The final project is an opportunity to demonstrate your proficiency in R programming and data analysis by conducting an end-to-end data science project. You will apply the skills learned throughout the course to analyze a real-world environmental or natural resource dataset of your choice.

== Project Objectives
<project-objectives>
+ Demonstrate proficiency in R programming fundamentals
+ Apply data manipulation and visualization techniques
+ Create reproducible research documentation
+ Practice version control and project management
+ Present findings effectively using R-based tools

== Project Components and Weights
<project-components-and-weights>
- #strong[Project Proposal (10%)] - Due Week 14
  - Dataset description and source
  - Research questions/objectives
  - Proposed analysis methods
  - Timeline for completion
- #strong[GitHub Repository (20%)]
  - Well-organized project structure
  - Clear documentation
  - Regular commits showing progress
  - README.md file with project description and instructions
- #strong[R Code and Analysis (40%)]
  - Clean, well-commented R scripts
  - Efficient use of tidyverse functions
  - At least three different types of data visualizations using ggplot2
  - Appropriate data cleaning and transformation steps
  - Error handling and code optimization
- #strong[Final Report (20%)]
  - Created using Quarto markdown
  - Professional formatting
  - Clear methodology description
  - Effective visualization presentation
  - Discussion of findings and limitations
  - 2,500-3,000 words (excluding code)
- #strong[Presentation (10%)] - Week 17
  - 10-minute presentation
  - 5-minute Q&A
  - Clear communication of findings
  - Demonstration of key code features

== Requirements
<requirements>
=== Dataset
<dataset>
- Minimum 150 observations
- At least 5 variables
- Must be related to environmental science or natural resources
- Can be public or private data (with appropriate permissions)
- Must require significant cleaning or transformation

=== Required Technical Elements
<required-technical-elements>
+ #strong[Data Processing]
  - Data import from at least two different file formats
  - Data cleaning and transformation using tidyverse
  - Creation of derived variables
+ #strong[Data Visualization]
  - Minimum three different types of plots using ggplot2
  - At least one complex visualization (multiple layers/facets)
  - Professional formatting and theming
+ #strong[Programming]
  - Use of functions
  - Proper error handling
  - Efficient code structure
  - Well-documented code
+ #strong[Version Control]
  - Minimum 15 meaningful GitHub commits
  - Clear commit messages
  - Proper .gitignore file
  - Well-structured repository

== Deliverables Timeline
<deliverables-timeline>
- Week 14: Project proposal due
- Week 15: Progress check-in
- Week 16: Code and repository review
- Week 17: Final presentation and submission of all materials

== Submission Requirements
<submission-requirements>
+ GitHub repository link containing:

  - All R scripts
  - Raw and processed data (or data access instructions)
  - Quarto markdown files
  - README.md with setup instructions

+ Final report in PDF format generated from Quarto

+ Presentation slides in PDF format

== Evaluation Criteria
<evaluation-criteria>
- Code quality and efficiency (25%)
- Data analysis depth and appropriateness (25%)
- Visualization effectiveness (20%)
- Documentation clarity (15%)
- Presentation quality (15%)

== Tips for Success
<tips-for-success>
- Start early and commit code regularly
- Choose a dataset that interests you
- Focus on clean, readable code
- Document your process thoroughly
- Test your analysis with different approaches
- Seek feedback during office hours
- Practice your presentation

== Academic Integrity
<academic-integrity>
- All code must be original or properly cited
- Data sources must be properly referenced
- Collaboration is encouraged for brainstorming, but all submitted work must be individual

This project is designed to be challenging but achievable with the skills learned in the course. It provides flexibility in topic selection while ensuring rigorous application of R programming concepts.

= Academic Policies
<academic-policies>
== AI Statement
<ai-statement>
Specific permissions will be provided to students regarding the use of generative artificial intelligence tools on certain graded activities in this course. In these instances, I will communicate explicit permission as well as expectations and any pertinent limitations for use and attribution. Without this permission, the use of generative artificial intelligence tools in any capacity while completing academic work submitted for credit, independently or collaboratively, will be considered academic dishonesty and reported to the Office of Academic Initiatives and Integrity.

== Academic Integrity
<academic-integrity-1>
As a core part of its mission, the University of Arkansas provides students with the opportunity to further their educational goals through programs of study and research in an environment that promotes freedom of inquiry and academic responsibility. Accomplishing this mission is only possible when intellectual honesty and individual integrity prevail.

Each University of Arkansas student is required to be familiar with and abide by the University’s #strong[Academic Integrity Policy] at #link("https://honesty.uark.edu/policy")[honesty.uark.edu/policy];. Students with questions about how these policies apply to a particular course or assignment should immediately contact their instructor.

== Emergency Preparedness
<emergency-preparedness>
The University of Arkansas is committed to providing a safe and healthy environment for study and work. In that regard, the university has developed a campus safety plan and an emergency preparedness plan to respond to a variety of emergency situations. The emergency preparedness plan can be found at #link("https://emergency.uark.edu")[emergency.uark.edu];. Additionally, the university uses a campus-wide emergency notification system, UARKAlert, to communicate important emergency information via email and text messaging. To learn more and to sign up: #link("http://safety.uark.edu/emergency-preparedness/emergency-notification-system/")

== Inclement Weather
<inclement-weather>
If you have any questions about whether or not class will be canceled due to inclement weather, please contact me. If I cancel class, I will notify you via email and/or Blackboard. In general, students need to know how and when they will be notified in the event that class is cancelled for weather-related reasons. Please see #link("http://safety.uark.edu/inclement-weather/")[here] for more information.

== Access and Accommodations
<access-and-accommodations>
Your experience in this class is important to me. University of Arkansas #link("https://provost.uark.edu/policies/152010.php")[Academic Policy Series 1520.10] requires that students with disabilities are provided reasonable accommodations to ensure their equal access to course content. If you have already established accommodations with the Center for Educational Access (CEA), please request your accommodations letter early in the semester and contact me privately, so that we have adequate time to arrange your approved academic accommodations.

If you have #strong[not] yet established services through CEA, but have a documented disability and require accommodations #emph[(conditions include but not limited to: mental health, attention-related, learning, vision, hearing, physical, health or temporary impacts)];, contact CEA directly to set up an Access Plan. CEA facilitates the interactive process that establishes reasonable accommodations. For more information on CEA registration procedures contact 479–575–3104, #link("mailto:ada@uark.edu")[ada\@uark.edu] or visit #link("https://cea.uark.edu/")[cea.uark.edu.]

== Academic Support
<academic-support>
A complete list and brief description of academic support programs can be found on the University’s Academic Support site, along with links to the specific services, hours, and locations. Faculty are encouraged to be familiar with these programs and to assist students with finding an using the support services that will help them be successful. Please see #link("http://www.uark.edu/academics/academic-support.php")[here] for more information.

== Religious Holidays
<religious-holidays>
The university does not observe religious holidays; however Campus Council has passed the following resolution concerning individual observance of religious holidays and class attendance:

#quote(block: true)[
When members of any religion seek to be excused from class for religious reasons, they are expected to provide their instructors with a schedule of religious holidays that they intend to observe, in writing, before the completion of the first week of classes.
]

= Schedule
<schedule>
Following materials are only allowed for previewing for students registered in ESRM 64503. DO NOT DISTRIBUTE THEM on the internet. They will be removed after the course ended.

#figure(
  align(center)[#table(
    columns: (3.08%, 9.23%, 36.41%, 43.08%, 2.56%, 5.64%),
    align: (left,left,left,left,left,auto,),
    table.header([Week], [Date], [Topic], [Reading], [HW], [Code/Data],),
    table.hline(),
    [1], [01/13], [Lecture 1: Basics of R], [#link("https://rafalab.dfci.harvard.edu/dsbook-part-1/R/getting-started.html")[ITDS Ch.1];], [], [],
    [2], [01/20 (No Class)], [Martin Luther King Holiday], [], [], [],
    [3], [01/27], [Lecture 2: Programming Basics], [], [], [],
    [4], [02/03], [Lecture 3: Write academic reports with R projects and Quarto markdown], [], [], [],
    [5], [02/10], [Lecture 4: Data summarization with #emph[tidyverse];], [], [], [],
    [6], [02/17], [Lecture 5: Data cleaning with #emph[tidyverse];], [], [], [],
    [7], [02/24], [Lecture 6: Data transformation with #emph[tidyverse];], [], [], [],
    [8], [03/03], [Lecture 7: Data Importing], [], [], [],
    [9], [03/10], [Lecture 8: Data Visualization I with #emph[ggplot2];], [], [], [],
    [10], [03/17], [Lecture 9: Data Visualization II with #emph[ggplot2];], [], [], [],
    [11], [03/24 (No class)], [Lecture 10: Data Visualization III with #emph[ggplot2];], [], [], [],
    [12], [03/31], [Spring Break], [], [], [],
    [13], [04/07], [Lecture 11: File Organizing with Terminal / Powershell], [], [], [],
    [14], [04/14], [Lecture 12: Git and GitHub], [#link("https://git-scm.com/book/en/v2")[Pro Git Book];], [], [],
    [15], [04/21], [Final Project], [], [], [],
    [16], [04/28], [Final Project], [], [], [],
    [17], [05/05], [Final Project], [], [], [],
  )]
  , kind: table
  )
