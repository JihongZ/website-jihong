# Image to text: 利用HuggingFace的pipeline实现模型的调用来将图片转换为文本
# Generate Text: 调用API接口生成对应的故事
# Text to Speech: 调用HuggingFace的API接口将文本转换为语音
# 使用LangChain将上面的功能串联起来

from langchain import PromptTemplate, LLMChain, OpenAI
from transformers import pipeline

# image to text
def img2text(img_path):
    image_to_text = pipeline("image-to-text", model="Salesforce/blip-image-captioning-base")
    text = image_to_text(img_path)
    return text

img2text("pic.jpg")[0]['generated_text']

# LLM

def generate_story(scenario):
    template = """你是一个讲故事的人，请根据下面的图片描述，生成一个故事。故事带有一些诙谐的色彩。
    图片描述：{scenario}
    故事：
    """
    
    prompt = PromptTemplate(template=template, input_variables=["scenario"])
    story_llm = LLMChain(
        llm=OpenAI(model="gpt-4o-mini", temperature=0.7),
        prompt=prompt,
        verbose=True
    )
    
    story = story_llm.predict(scenario=scenario)
    return story

# Text to Speech

scenario_text = img2text("pic.jpg")[0]['generated_text']
story = generate_story(scenario = scenario_text)


from kokoro import KPipeline
from IPython.display import display, Audio
generator = pipeline(text, voice='af_heart')
for i, (gs, ps, audio) in enumerate(generator):
    print(i, gs, ps)
    display(Audio(data=audio, rate=24000, autoplay=i==0))
    sf.write(f'{i}.wav', audio, 24000)