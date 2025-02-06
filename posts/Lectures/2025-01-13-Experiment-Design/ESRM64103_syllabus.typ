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
  title: [ESRM 64103: Experimental Design In Education],
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
#box(image("images/logo_ESRM64103.png", width: 512))
]
= General Information
<general-information>

#horizontalrule

- Course Code: ESRM 64103
- Credits: 3 CH
- Course time and location: Mon 17:00-19:45; GRAD 239
- Instructor: Dr.~Jihong Zhang
- Contact Information: #link("mailto:jzhang@uark.edu")[jzhang\@uark.edu]
- Personal Website: #link("http://jihongzhang.org")
- Office Location: GRAD 133B
- Office Hours: Monday 2:00-5:00PM or by appointment
- Office Phone +1 479-575-5235
- Semester: Spring 2025

= Course Overview
<course-overview>
== Course Objectives:
<course-objectives>
The purpose of the course is to enhance your understanding of how to analyze and interpret research data using analysis-of-variance (ANOVA) techniques. The course builds upon your foundation from ESRM 64003 (#strong[Educational Statistics and Data Processing];) and will lead into the methods in subsequent ESRM courses. The specific educational objectives of the course are as follows:

- To select appropriate statistical techniques given the research methods employed and research questions asked

- To understand what affects each of the statistics discussed

- We will use R language to display data and conduct statistical analyses. However, it is also necessary to build a mathematical framework to understand the nature of the procedures and to enable you to troubleshoot or design appropriate analysis strategies for unique research situations. Both computing skills and mathematical perspectives will be helpful in preparing for continued study of research methodology and applied statistics.

- We will thoughtfully apply both descriptive and inferential methods to analyze the empirical data.

- In addition to conducting analyses using statistical software, we will interpret, write, and discuss the results in accordance with APA format.

- The course is not a mathematics course; however, students must have a conceptual understanding of each of the methods so that they will apply and interpret statistical techniques in an appropriate and, in some cases, creative fashion.

== Course Topics
<course-topics>
+ Identification of ANOVA Designs
+ Model Comparison: Two-Group Situation
+ Model Comparison: General Case of One-Way Designs
+ Tests of Comparisons
+ Multiple Comparisons
+ Brief Overview of Trend Analysis
+ Two-Way Between-Subjects Factorial Designs
+ Interactions and simple main effects
+ One-Way Within-Subjects Designs: Univariate Approach
+ Two-Way Within-Subjects Designs: Univariate Approach
+ Designs with both Between-Subjects and Within-Subjects Factors

== Prerequisites
<prerequisites>
Educational Statistics and Data Processing (ESRM 64003) or an equivalent course with a grade of C or better.

== Recommended Textbooks
<recommended-textbooks>
- Maxwell, S. E., Delaney, H. D., & Kelley K. (2017). #emph[Designing experiments and analyzing data: A model comparison perspective] (3rd ed.). Routledge.
- Fox, J. 2008. #emph[Applied Regression Analysis and Generalized Linear Models];. Second. Thousand Oaks, CA: Sage.
- Kuhn, M., Silge J. (2023). #emph[Tidy Modeling with R];. #link("https://www.tmwr.org/")

== Resources
<resources>
All course materials, such as the lecture notes, and the resources of homework and project instructions, will be posted on the Blackboard system (https:\/\/learn.uark.edu/webapps/login/). Because this course will cover the computer program practice, it is recommended to bring your own laptop to class. Except the exams, all course assignments will be submitted through the Blackboard system by the due date.

=== Online Resources
<online-resources>
+ #link("https://statsandr.com/blog/anova-in-r/")[Blog: ANOVA in R]

== Attendance
<attendance>
In an in-person course at graduate level, there are not really any attendance issues. If you know that you will be out of town for a few days when an assignment is due, it is expected that you will make arrangements to complete the assignment before you leave. The deadlines are set as a designation of the maximum amount of time that you should allow.

= Assignment
<assignment>
== Homework
<homework>
Homework will be provided for instructional and evaluation purposes. You will notice that each homework is due approximately every two weeks. The homework will be a set of questions related to the course materials including the lectures and the computer program practices. #strong[I highly recommend you finish your homework and submit it by the due date through my website (see @sec-homeworkportal Homework portal)];. This will keep you on track to complete the course in the weeks allocated.

== Grading for Criteria
<grading-for-criteria>
This is a Graduate level class. As such, students are expected to read the chapters of the textbooks and lecture notes, attend the in-person classes, carefully complete all assignments, and participate in class activities. Students who do this typically earn passing grades in the course. More specifically, the grades will be calculated based on the following point system:

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [Raw Score], [Proportion],),
    table.hline(),
    [Homeworks], [88], [88%],
    [In-Class Quiz], [12], [12%],
    [Bonus points], [10], [],
    [#strong[Total];], [#strong[110];], [#strong[100%];],
  )]
  , caption: [Proportional Scoring]
  , kind: table
  )

The grading scale employed in this course is the following:

#figure(
  align(center)[#table(
    columns: 2,
    align: (auto,auto,),
    table.header([Percentage of Points], [Grade],),
    table.hline(),
    [100-90], [A],
    [89-90], [B],
    [79-70], [C],
    [69-60], [D],
    [\< 60], [F],
  )]
  , kind: table
  )

= Academic Policies
<academic-policies>
== AI Statement
<ai-statement>
Specific permissions will be provided to students regarding the use of generative artificial intelligence tools on certain graded activities in this course. In these instances, I will communicate explicit permission as well as expectations and any pertinent limitations for use and attribution. Without this permission, the use of generative artificial intelligence tools in any capacity while completing academic work submitted for credit, independently or collaboratively, will be considered academic dishonesty and reported to the Office of Academic Initiatives and Integrity.

== Academic Integrity
<academic-integrity>
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

= Homework Portal
<sec-homeworkportal>
+ #link("https://forms.office.com/r/v5QU6KMgXc")[ESRM64103: EDIC Assignment Demo] (2 bonus points)
+ Homework 1
+ Homework 2
+ Homework 3

Please the online #link("Grade.qmd")[gradebook] for your current grade.

= Schedule
<schedule>
Following materials are only allowed for previewing for students registered in ESRM 64103. DO NOT DISTRIBUTE THEM on the internet. They will be removed after the course ended. #strong[All homework are due at noon on next Monday.]

#figure(
  align(center)[#table(
    columns: (5%, 10%, 40%, 25%),
    align: (left,left,left,left,),
    table.header([Week], [Date], [Topic], [HW],),
    table.hline(),
    [1], [01/13], [#link("Lecture01/Lecture01.qmd")[Lec1: Welcome to ESRM 64103]

    #link("Lecture01/MakeFriendsWithR.qmd")[Example01 - MakeFriendsWithR.qmd]

    Data: #link("Lecture01/heights.csv")[heights.csv]

    Data: #link("Lecture01/wide.sav")[wide.sav]

    #link("Lecture01/ExtraCode.R")[ExtraCode.R]

    ], [#link("https://forms.office.com/r/v5QU6KMgXc")[ESRM64103: EDIC Assignment Demo];],
    [2], [01/20], [#strong[No Class];; M.L.K. Holiday], [],
    [3], [01/27], [#link("Lecture02/ESRM64103_Lecture02.qmd")[Lec2: Hypothesis testing];], [#link("https://forms.office.com/Pages/ResponsePage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAANAAbGr9vVUQlNUUjFTQ09ISU1WODM1QzZDRlZLR0xZTS4u")[HW\#1]

    Due on 02/03 5PM

    ],
    [4], [02/03], [#link("Lecture03/ESRM64103_Lecture03.qmd")[Lec3: One-way ANOVA];], [#link("Lecture02/ESRM64103_HW1_QA.qmd")[HW\#1 Answer];],
    [5], [02/10], [#link("Lecture04/ESRM64103_Lecture04.qmd")[Lec4: Comparison and Contrast (Assumption Checking)];], [],
    [6], [02/17], [Lec5: Comparison and Contrast (2)], [HW\#2],
    [7], [02/24], [Lec6: Validity], [],
    [8], [03/03], [Lec7: Blocking designing (1)], [],
    [9], [03/10], [Lec8: Blocking design (2)], [],
    [10], [03/17], [Lec9: 2-Way ANOVA (1)], [],
    [11], [03/24], [#strong[Spring break: No Class];], [],
    [12], [03/31], [Lec10: 2-Way ANOVA (2)], [],
    [13], [04/07], [Lec11: Repeated Measure ANOVA], [HW\#3],
    [14], [04/14], [Lec12: ANCOVA], [],
    [15], [04/21], [#strong[2025 AERA Conference: No Class];], [],
    [16], [04/28], [Lec13: Mixed Design], [],
    [17], [05/05], [Homework Q&A], [],
  )]
  , caption: [Weekly Schedule]
  , kind: table
  )
