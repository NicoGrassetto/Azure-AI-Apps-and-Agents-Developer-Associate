# Extract insights from visual data on Azure
## Develop a vision-enabled generative AI application
### Introduction

Generative AI models enable you to develop chat-based applications that reason over and respond to input. Often this input takes the form of a text-based prompt, but increasingly multimodal models that can respond to visual input are becoming available.

This module discusses vision-enabled generative AI and explores how you can use Microsoft Foundry to create generative AI solutions that respond to prompts that include a mix of text and image data.

### Use a vision-capable model in the Microsoft Foundry portal

To handle prompts that include images, you need to deploy a *multimodal* generative AI model - in other words, a model that supports not only text-based input, but image-based (and in some cases, audio-based) input as well. Multimodal models available in Microsoft Foundry include (among others):

- Microsoft **Phi-4-multimodal-instruct**
- OpenAI **gpt-4.1**
- OpenAI **gpt-4.1-mini**

#### Testing multimodal models with image-based prompts

After deploying a multimodal model, you can test it in the chat playground in Microsoft Foundry portal. You can upload an image from a local file and add text to the message to elicit a response from a multimodal model.

### Develop a vision-based chat app

To develop a client app that engages in vision-based chats with a multimodal model, you can use the same basic techniques used for text-based chats. You require a connection to the endpoint where the model is deployed, and you use that endpoint to submit prompts that consist of messages to the model and process the responses.

The key difference is that prompts for a vision-based chat include multi-part user messages that contain both a *text* content item and an *image* content item.

#### Submit an image-based prompt using the *Responses* API

To include an image in a prompt using the *Responses* API, specify a URL for a web-based image file, or load a local image and encode its data in Base64 format and submit a URL in the format `data:image/jpeg;base64,{image_data}` (replacing "jpeg" with "png" or other formats as appropriate).

```python
# Read the image data from a local file
image_path = Path("dragon-fruit.jpeg")
image_format = "jpeg"
with open(image_path, "rb") as image_file:
    image_data = base64.b64encode(image_file.read()).decode("utf-8")

data_url = f"data:image/{image_format};base64,{image_data}" # You can also use a web URL

# Send the image data in a prompt to the model
response = client.responses.create(
    model="gpt-4.1",
    input=[
        {"role": "developer", "content": "You are an AI assistant for chefs planning recipes."},
        {"role": "user", "content": [  
            { "type": "input_text", "text": "What desserts could I make with this?"},
            { "type": "input_image", "image_url": data_url}
        ] } 
    ]
)
print(response.output_text)
```

#### Submit an image-based prompt using the *ChatCompletions* API

When using the Azure OpenAI endpoint to submit prompts to models that don't support the *Responses* API, you can use the *ChatCompletions* API:

```python
# Read the image data from a local file
image_path = Path("orange.jpeg")
image_format = "jpeg"
with open(image_path, "rb") as image_file:
    image_data = base64.b64encode(image_file.read()).decode("utf-8")

data_url = f"data:image/{image_format};base64,{image_data}" # You can also use a web URL

# Send the image data in a prompt to the model
response = client.chat.completions.create(
    model="Phi-4-multimodal-instruct",
    messages=[
        {"role": "system", "content": "You are an AI assistant for chefs planning recipes."},
        { "role": "user", "content": [  
            { "type": "text", "text": "What can I make with this fruit?"},
            { "type": "image_url", "image_url": {"url": data_url}}
        ] }
    ]
)
print(response.choices[0].message.content)
```

## Generate images with AI
### Introduction

With Microsoft Foundry, you can use language models to generate content based on natural language prompts. Often the generated content is in the form of natural language text, but increasingly, models can generate other kinds of content. For example, the OpenAI *gpt-image-1* model can create original graphical content based on a description of a desired image.

The ability to use AI to generate graphics has many applications; including the creation of illustrations or photorealistic images for articles or marketing collateral, generation of unique product or company logos, or any scenario where a desired image can be described.

### What are image-generation models?

Microsoft Foundry supports multiple models that are capable of generating images, including (but not limited to):

- The OpenAI *gpt-image-1* series of models.
- The Black Forest Labs *FLUX* series of models.

Image generation models are generative AI models that can create graphical data from natural language input. You can provide the model with a description and it can generate an appropriate image. For example, you might submit the prompt *A robot eating spaghetti* and the model generates an appropriate image.

The images generated are original; they aren't retrieved from a curated image catalog. In other words, the model isn't a search system for *finding* appropriate images - it is an AI model that *generates* new images based on the data on which it was trained.

### Explore image-generation models in Microsoft Foundry portal

To experiment with image generation models, you can create a Microsoft Foundry project and use the *model playground* in Microsoft Foundry portal to submit prompts and view the resulting generated images.

When using the playground (subject to model support), you can specify the resolution (size) of the generated images and include a reference image for the model to base its output on.

### Create a client application that uses an image generation model

You can use a language-specific SDK (for example, the OpenAI Python SDK or the Azure OpenAI .NET SDK) to develop client applications that use models to generate images.

The following Python code uses the OpenAI *Images* API to submit a request to a model to generate an image of a robot eating a cheeseburger:

```python
# Generate an image
img_results = client.images.generate(
    model="FLUX.1-Kontext-pro",
    prompt="A robot eating a cheeseburger.",
    n=1,
    size="1024x1024",
)

# Save the generated image
image_data = base64.b64decode(img_results.data[0].b64_json)
with open("image.png", "wb") as image_file:
    image_file.write(image_data)
```

The result is a binary stream containing the requested image.

## Generate videos with Microsoft Foundry
### Introduction

Generative AI has expanded beyond text and images to video creation. With Sora 2 in Microsoft Foundry, you can generate realistic and imaginative video scenes from text prompts, reference images, or by remixing existing videos.

### Deploy a video generating model

To generate videos from text prompts, you need to deploy a video generation model. **Sora 2** is an AI model from OpenAI that creates realistic and imaginative video scenes from text instructions, input images, or existing videos. Sora 2 is available in Microsoft Foundry and provides an all-in-one creative platform with superior video quality and intuitive controls.

#### Deploy the Sora 2 model

1. Go to the Microsoft Foundry portal and sign in with your credentials.
2. From the Foundry landing page, create or select a project.
3. Select **Build** from the navigation pane on the right.
4. Select **Models** from the left-hand menu to view the model catalog.
5. Use the search bar or filter options to find the **Sora-2** video generation model.
6. Select the **Sora-2** model then select **Deploy** and choose the appropriate deployment settings.

#### Sora 2 capabilities

| Feature | Description |
| --- | --- |
| **Text to video** | Generate videos from natural language text prompts |
| **Image to video** | Transform existing images into video content |
| **Video remix** | Make targeted adjustments to existing videos without regenerating from scratch |
| **Audio generation** | Supports audio generation in output videos |
| **Multiple resolutions** | Supports portrait (720×1280) and landscape (1280×720) formats |
| **Variable duration** | Generate videos of 4, 8, or 12 seconds |

### Generate video from a prompt

Video generation is an asynchronous process - you submit a request with your prompt and video settings, then retrieve the completed video when it's ready.

#### Video generation parameters

| Parameter | Description | Supported values |
| --- | --- | --- |
| **prompt** | Natural language description of your video | Text string (required) |
| **model** | The model to use | `sora-2` or `sora-2-pro` |
| **size** | Output resolution | `1280x720` (landscape), `720x1280` (portrait) |
| **seconds** | Video duration | `4`, `8`, or `12` (default: 4) |
| **input_reference** | Reference image for the first frame | JPEG, PNG, or WebP file |
| **remix_video_id** | ID of a previous video to remix | Video ID string |

>**Tip**: The model follows instructions more reliably in shorter clips. For best results, consider generating two 4-second clips and stitching them together rather than a single 8-second clip.

>**Note**: The content generation APIs include a content moderation filter. If Azure OpenAI recognizes your prompt as harmful content, it won't return a generated video.

#### Writing effective prompts

Think of prompting like briefing a cinematographer. A clear prompt describes a shot as if you were sketching it onto a storyboard:

- **Camera framing**: Specify the shot type (wide, medium, close-up) and angle
- **Subject description**: Anchor your subject with distinctive details
- **Action**: Describe movement in beats - small steps, gestures, or pauses
- **Lighting and palette**: Set the mood with lighting direction and color anchors
- **Style**: Establish the aesthetic early (for example, "1970s film" or "handheld documentary")

| Weak prompt | Strong prompt |
| --- | --- |
| "A beautiful street at night" | "Wet asphalt, zebra crosswalk, neon signs reflecting in puddles" |
| "Person moves quickly" | "Cyclist pedals three times, brakes, and stops at crosswalk" |
| "Cinematic look" | "Anamorphic 2.0x lens, shallow DOF, volumetric light" |

Example prompt:

```text
In a 90s documentary-style interview, an old Swedish man sits in a study 
and says, "I still remember when I was young."
```

#### Using reference images

For more control over composition and style, use the `input_reference` parameter to provide a visual reference. The model uses the image as an anchor for the first frame. The image resolution must match the target video size (`1280x720` or `720x1280`); supported formats are JPEG, PNG, WebP.

#### Remixing existing videos

The remix feature lets you modify specific aspects of an existing video while preserving its core elements - scene transitions, visual layout, and overall structure. Limit changes to one clearly articulated adjustment and be specific about what to change.

### Generate video in Python

Video generation follows a three-step pattern: create the job, poll for completion, and download the result.

```python
import time

# Create the video generation job
video = client.videos.create(
    model="sora-2",
    prompt="A robot walks through a rainy city street at dusk, neon signs reflecting in puddles",
    size="1280x720",
    seconds="4",
)

print(f"Video creation started. ID: {video.id}")

# Poll for completion
while video.status not in ["completed", "failed", "cancelled"]:
    print(f"Status: {video.status}. Waiting...")
    time.sleep(20)
    video = client.videos.retrieve(video.id)

# Download when complete
if video.status == "completed":
    content = client.videos.download_content(video.id, variant="video")
    content.write_to_file("output.mp4")
    print("Video saved to output.mp4")
```

#### Generate video from a reference image

```python
video = client.videos.create(
    model="sora-2",
    prompt="The camera slowly pans across the landscape as clouds drift overhead",
    size="1280x720",
    seconds="4",
    input_reference=open("landscape.png", "rb"),
)
```

>**Note**: Reference images containing human faces are currently rejected. Use images of landscapes, objects, or animated characters instead.

#### Remix an existing video

```python
video = client.videos.remix(
    video_id="video_abc123",
    prompt="Change the color palette to warm sunset tones",
)
```

#### Handle job states

| Status | Description |
| --- | --- |
| `queued` | Job is waiting to be processed |
| `in_progress` | Video is being generated |
| `completed` | Video is ready for download |
| `failed` | Generation failed (check error details) |
| `cancelled` | Job was canceled |

#### Key considerations

- **Rate limits**: You can run up to two video creation jobs simultaneously
- **Job expiration**: Completed videos are available for download for 24 hours
- **Resolution requirements**: Reference images must match the target video resolution exactly
- **Content filtering**: Prompts are subject to content moderation; harmful content won't generate

## Analyze images with Content Understanding
### Introduction

Images, documents, and other unstructured content often contain valuable information that's hard to extract automatically. Azure Content Understanding solves this problem by using generative AI to analyze content and return structured data. You define a schema describing the data you want, and the service extracts it from your images and documents. The output is ready to use in automation workflows, analytics, and search applications.

### What is Content Understanding?

Azure Content Understanding is a Foundry Tool that uses generative AI to process and extract insights from many types of content, including documents, images, videos, and audio. It transforms unstructured data into structured, actionable output that you can integrate into automation and analytical workflows.

#### Why use Content Understanding?

Content Understanding accelerates time to value by enabling straight-through processing of unstructured data. Key benefits include:

- **Simplified workflows**: Standardizes extraction and classification of content from various content types into a unified process
- **Easy field extraction**: Define a schema to extract, classify, or generate field values without complex prompt engineering
- **Enhanced accuracy**: Uses multiple AI models to analyze and cross-validate information simultaneously
- **Confidence scores and grounding**: Ensures accuracy of extracted values while minimizing the cost of human review
- **Content classification**: Categorize document types to streamline processing and route content to appropriate analyzers

#### Content Understanding components

| Component | Description |
| --- | --- |
| **Inputs** | Source content including documents, images, video, and audio |
| **Analyzer** | Defines how content is processed, including extraction settings and field schema |
| **Content extraction** | Transforms unstructured input into normalized text and metadata using OCR, speech transcription, and layout detection |
| **Field extraction** | Generates structured key-value pairs based on your defined schema |
| **Confidence scores** | Provides reliability estimates from 0 to 1 for each extracted field value |
| **Grounding** | Identifies specific regions in content where each value was extracted |
| **Structured output** | Final result as Markdown for search scenarios or JSON for automation workflows |

#### Analyzers

Analyzers are the core component that defines how your content is processed. Content Understanding offers two types:

- **Prebuilt analyzers**: Ready-to-use analyzers designed for common scenarios like invoice processing, receipt extraction, and call center analytics
- **Custom analyzers**: Tailored analyzers you create with your own field schema for specific business needs

When you create an analyzer, you configure:

- The base analyzer type (document, image, audio, or video)
- The AI models to use for processing
- The field schema that defines what data to extract
- Options like confidence scoring and content segmentation

#### Use cases

| Use case | Description |
| --- | --- |
| **Intelligent document processing** | Convert unstructured documents into structured data for invoice processing, contract analysis, and claims management |
| **Search and RAG** | Ingest multimodal content into search indexes with figure descriptions and layout analysis |
| **Agentic applications** | Transform messy file inputs into predictable, standardized inputs for AI agents |
| **Analytics and reporting** | Extract field outputs to gain insights and make informed decisions |

#### Content restrictions

Content Understanding includes built-in Responsible AI protections. The service integrates Azure AI Content Safety to detect and prevent harmful content:

- Content is filtered for harmful material including violence, hate speech, and exploitation
- Face description capabilities can identify facial attributes in video and image content
- Biometric data processing requires appropriate notice and consent from data subjects

### Analyze images with Content Understanding

Content Understanding can analyze images to extract structured data, identify visual elements, and generate descriptions. You can use prebuilt analyzers for common scenarios or create custom analyzers tailored to your specific needs.

#### Supported image formats

| Format | Description |
| --- | --- |
| **JPEG** | Standard photographic images |
| **PNG** | Images with transparency support |
| **BMP** | Bitmap images |
| **TIFF** | High-quality scanned documents |
| **HEIF** | High-efficiency image format |
| **PDF** | Single or multi-page documents with embedded images |

#### Prebuilt image analyzers

- **prebuilt-image**: General-purpose image analysis with content extraction and figure description
- **prebuilt-receipt**: Extract vendor names, items, totals, and dates from receipt images
- **prebuilt-invoice**: Extract invoice details including line items, amounts, and vendor information
- **prebuilt-idDocument**: Extract information from identity documents like driver's licenses and passports

#### Define a field schema for images

To extract specific information from images, define a field schema that describes the data you want. Each field can use one of three extraction methods:

| Method | Description | Example |
| --- | --- | --- |
| **extract** | Pull values directly as they appear in the image | Extract text from a label or sign |
| **classify** | Categorize content from predefined options | Classify image as "damaged" or "undamaged" |
| **generate** | Create values based on image analysis | Generate a description of the scene |

Example schema for analyzing product images:

```json
{
  "description": "Product image analyzer",
  "baseAnalyzerId": "prebuilt-image",
  "fieldSchema": {
    "fields": {
      "ProductName": {
        "type": "string",
        "method": "extract",
        "description": "Name of the product visible in the image"
      },
      "Condition": {
        "type": "string",
        "method": "classify",
        "description": "Condition of the product",
        "enum": ["new", "used", "damaged"]
      },
      "Description": {
        "type": "string",
        "method": "generate",
        "description": "Brief description of what the image shows"
      }
    }
  }
}
```

#### Analyze an image

Install the Python SDK using `pip`:

```bash
pip install azure-ai-contentunderstanding
```

Submit a request to the analyze endpoint with your analyzer ID and the image URL or file:

```python
from azure.ai.contentunderstanding import ContentUnderstandingClient
from azure.ai.contentunderstanding.models import AnalysisInput, AnalysisResult
from azure.core.credentials import AzureKeyCredential # for key-based authentication
from azure.identity import DefaultAzureCredential # for Entra ID authentication

# Get a client
credential = AzureKeyCredential(key)
client = ContentUnderstandingClient(endpoint={FOUNDRY_ENDPOINT},
                                    credential={KEY_OR_IDENTITY},
                                    api_version="2025-11-01")

# Analyze an image file
with open("my_image.png", "rb") as f:
            file_bytes = f.read()

try:
    poller = client.begin_analyze(
        analyzer_id={ANALYSER_ID},
        inputs=[AnalysisInput(data=file_bytes)],
    )
    # Get results asynchronously from poller
    result: AnalysisResult = poller.result()

    # Display results
    result_str = json.dumps(result.as_dict(), indent=2)
    print (result_str)

except Exception as ex:
    print(f"[Unexpected Error]: {ex}")
    sys.exit(1)
```

When analysis completes, the results include the extracted content:

- **markdown**: A text representation of the image content, useful for search and RAG scenarios
- **fields**: Extracted field values matching your schema, each with a confidence score
- **source**: Grounding information showing where in the image each value was found

Example response for a product image:

```json
{
  "contents": [
    {
      "markdown": "Product label showing 'Contoso Widget Pro' with serial number...",
      "fields": {
        "ProductName": {
          "type": "string",
          "valueString": "Contoso Widget Pro",
          "confidence": 0.95,
          "source": "D(1,100,50,300,50,300,80,100,80)"
        },
        "Condition": {
          "type": "string",
          "valueString": "new",
          "confidence": 0.89
        },
        "Description": {
          "type": "string",
          "valueString": "A silver electronic device in retail packaging with product label visible"
        }
      }
    }
  ]
}
```

#### Use confidence scores

Each extracted field includes a confidence score from 0 to 1:

- **High confidence (0.9+)**: Value can be trusted for automated processing
- **Medium confidence (0.7-0.9)**: Consider human review for critical applications
- **Low confidence (<0.7)**: Recommend manual verification

Use confidence scores to build automation workflows that route low-confidence extractions to human reviewers while processing high-confidence results automatically.

#### Tips for better image analysis

- **Image quality matters**: Higher resolution images produce more accurate extractions
- **Lighting and contrast**: Ensure text and visual elements are clearly visible
- **Single focus**: Images with one clear subject yield better results than cluttered scenes
- **Consistent orientation**: Upright images are processed more reliably than rotated ones

## Analyze content with Content Understanding
### Introduction

Organizations today rely on information that is often locked up in content assets such as documents, images, videos, and audio recordings. Extracting information from this content can be challenging, laborious, and time-consuming, and organizations often need to build solutions based on multiple technologies for content analysis depending on the formats being used. Azure Content Understanding is a multimodal service that simplifies the creation of AI-powered analyzers that can extract information from content in practically any format.

### What is Azure Content Understanding?

Azure Content Understanding is a generative AI service that you can use to extract insights and data from multiple kinds of content. With Content Understanding, you can quickly build applications that analyze complex data and generate outputs that can be used to automate and optimize processes.

Content Understanding is available through Microsoft Foundry. To use it, you need to provision a Microsoft Foundry resource in your Azure subscription. You can develop and manage a Content Understanding solution:

- In the Microsoft Foundry portal
- In Content Understanding Studio
- By using the Content Understanding API

#### Multimodal content analysis

Content Understanding can extract information from common kinds of content, enabling you to use a single service with a straightforward and consistent development process to build multimodal content analysis solutions.

- **Documents and forms**: Analyze documents and forms and retrieve specific field values. For example, extract key data values from an invoice to automate payment processing.
- **Images**: Analyze images to infer information from visuals such as charts, identify physical defects in products or other items, detect the presence of specific objects or people, or determine other information visually.
- **Audio**: Automate tasks like summarizing conference calls, determining sentiment of recorded customer conversations, or extracting key data from telephone messages.
- **Video**: Analyze and extract insights from video to support many scenarios - for example, to extract key points from video conference recordings, to summarize presentations, or to detect the presence of specific activity in security footage.

### Create a Content Understanding analyzer

Content Understanding solutions are based on the creation of an *analyzer*, which is trained to extract specific information from a particular type of content based on a *schema* that you define.

The high-level process for creating a Content Understanding solution includes the following steps:

1. Create a Foundry resource.
2. Define a Content Understanding schema for the information to be extracted. This can be based on a content sample and an analyzer template.
3. Build an analyzer based on the completed schema.
4. Use the analyzer to extract or generate fields from new content.

Numerous analyzer templates are provided to help you develop an appropriate analyzer for your needs quickly. Additionally, because of the generative AI capabilities of Content Understanding, you can use minimal training data to define a schema by example. In many cases, the service accurately identifies the data values in the sample content that map to the schema elements automatically, though you can also explicitly label fields in content such as documents to improve the performance of your analyzer.

#### Creating an analyzer with Content Understanding Studio

While you can develop a complete Content Understanding solution through the API or a language specific SDK, Content Understanding Studio provides a visual interface to create a project, define a Content Understanding schema, and build and test an analyzer.

>**Tip**: Only certain prebuilt models are available for use directly in the Microsoft Foundry portal. For custom analyzer creation and testing, use **Content Understanding Studio**.

**Creating a Content Understanding project**: In Content Understanding Studio, you can create a new project that is associated with a Microsoft Foundry resource. Creating a project provisions the Azure resources needed to support your Content Understanding solution, including storage and a key vault resource to store sensitive details like credentials and keys.

**Defining a schema**: After creating a project, the first step in building an analyzer is to define a schema for the content the analyzer will process, and the information it will extract. Content Understanding Studio provides a schema editor interface in which you can upload a file (document, image, audio, or video) on which the schema should be based. You can then apply an appropriate schema template and define the specific fields you want the analyzer to identify.

>**Note**: The templates and field types available in a schema depend on the content type of the file on which the schema is based. Some content types support additional optional functionality, such as extracting barcodes and formulae from text in documents.

**Testing**: You can test the analyzer schema at any time during the development process by running analysis on the sample file used to define the schema or other uploaded files. The test results include the extracted field values and the JSON format output returned by the analyzer to client applications.

**Building an analyzer**: When you're satisfied with the performance of your schema, you can build your analyzer. Building an analyzer makes it accessible to client applications through the endpoint for the Microsoft Foundry resource associated with your project. After building your analyzer, you can continue to test it in Content Understanding Studio, and refine the schema to create new named versions with different capabilities.

### Use the Content Understanding API

The Content Understanding API provides a programmatic interface that you can use to create, manage, and consume analyzers.

To use the API, your client application submits HTTP calls to the Content Understanding endpoint for your Microsoft Foundry resource, passing one of the authorization keys in the header. You can obtain the endpoint and keys in the Azure portal or in the Microsoft Foundry portal. You can also use the Microsoft Foundry API to connect to the project programmatically with your Entra ID.

#### Using the API to analyze content

One of the most common uses of the API is to submit content to an existing analyzer that you have previously built, and retrieve the results of analysis. The analysis request returns an operation ID value that represents an asynchronous task. Your client application must then use another request to pass the operation ID back to the endpoint and retrieve the operation status - potentially polling multiple times until the operation is complete and the results are returned in JSON format.

For example, to analyze a document, a client application might submit a POST request to the `analyze` function containing the following JSON body:

```json
POST {endpoint}/contentunderstanding/analyzers/{analyzer}:analyze?api-version=2025-11-01
{
  "inputs": [
    {
      "url": "https://host.com/doc.pdf"
    }
  ]
}
```

>**Note**: You can specify a URL for the content file location as shown here. To submit binary file data directly, use the `analyzeBinary` operation instead.

Assuming the request is authenticated and initiated successfully, the response will be similar to this example:

```http
Operation-Id: 1234abcd-1234-abcd-1234-abcd1234abcd
Operation-Location: {endpoint}/contentunderstanding/analyzerResults/1234abcd-1234-abcd-1234-abcd1234abcd?api-version=2025-11-01
{
  "id": "1234abcd-1234-abcd-1234-abcd1234abcd",
  "status": "NotStarted"
}
```

Your client application must then use the operation ID that has been returned to check the status of the operation until it has succeeded (or failed) by submitting a GET request to the `analyzerResults` endpoint.

```http
GET {endpoint}/contentunderstanding/analyzerResults/1234abcd-1234-abcd-1234-abcd1234abcd?api-version=2025-11-01
```

When the operation has completed successfully, the response contains a JSON payload representing the results of the analysis. The specific results depend on the content and schema.

## Create a Content Understanding client application
### Introduction

Azure Content Understanding is a multimodal service that simplifies the creation of AI-powered analyzers that can extract information from multiple content formats, including documents, images, audio files, and videos. You can develop client applications that use Azure Content Understanding analyzers by using the Python SDK or the REST API.

### Prepare to use the AI Content Understanding API

Before you can use the Azure Content Understanding API, you need a Microsoft Foundry resource in your Azure subscription. You can provision this resource in the following ways:

- Create a **Microsoft Foundry** resource in the Azure portal.
- Create a **Microsoft Foundry** project, which includes a Microsoft Foundry resource by default.

After you've provisioned a Microsoft Foundry resource, you need the following information to connect to the Azure Content Understanding API from a client application:

- The Microsoft Foundry resource *endpoint*
- One of the API *keys* associated with the endpoint

You can obtain these values from the Azure portal. If you're working within a Microsoft Foundry project, you can find the endpoint and key for the associated Foundry resource in the Foundry portal project home page. When working in a Microsoft Foundry project, you can also write code that uses the Microsoft Foundry SDK to connect to the project using Microsoft Entra ID authentication, and retrieve the connection details for the Microsoft Foundry resource.

#### Installing the Python SDK

To use the Python SDK for Content Understanding, install the `azure-ai-contentunderstanding` package:

```bash
pip install azure-ai-contentunderstanding
```

>**Note**: The Python SDK requires Python 3.9 or later. You can also use the REST API directly from any language that supports HTTP requests.

>**Important**: Before using the Content Understanding API, you must set up default model deployments for your Microsoft Foundry resource. Content Understanding requires `GPT-4.1`, `GPT-4.1-mini`, and `text-embedding-3-large` model deployments. You can configure these in the Azure portal or by using the API.

### Create a Content Understanding analyzer

In most scenarios, you should consider creating and testing analyzers using the visual interface in Content Understanding Studio. However, in some cases you might want to create an analyzer by submitting a JSON definition of the schema for your desired content fields to the API.

#### Defining a schema for an analyzer

Analyzers are based on schemas that define the fields you want to extract or generate from a content file. At its simplest, a schema is a set of fields, which can be specified in a JSON document:

```json
{
    "description": "Simple business card",
    "baseAnalyzerId": "prebuilt-document",
    "config": {
        "returnDetails": true
    },
    "fieldSchema": {
        "fields": {
            "ContactName": {
                "type": "string",
                "method": "extract",
                "description": "Name on business card"
            },
            "EmailAddress": {
                "type": "string",
                "method": "extract",
                "description": "Email address on business card"
            }
        }
    },
    "models": {
        "completion": "gpt-4.1",
        "embedding": "text-embedding-3-large"
    }
}
```

This example of a custom analyzer schema is based on the pre-built *document* analyzer, and describes two fields that you would expect to find on a business card: *ContactName* and *EmailAddress*. Both fields are defined as string data types, and are expected to be *extracted* from a document (the string values are expected to exist in the document so they can be "read", rather than being fields that can be *generated* by inferring information about the document). The `models` object specifies the generative models that the analyzer uses for processing.

#### Using the Python SDK to create an analyzer

The `ContentUnderstandingClient` class provides a `begin_create_analyzer` method that handles the asynchronous creation process for you.

```python
from azure.ai.contentunderstanding import ContentUnderstandingClient
from azure.core.credentials import AzureKeyCredential

# Authenticate the client
endpoint = "<YOUR_ENDPOINT>"
credential = AzureKeyCredential("<YOUR_API_KEY>")
client = ContentUnderstandingClient(endpoint=endpoint, credential=credential)

# Define the analyzer
analyzer_name = "business_card_analyser"
analyzer_definition = {
    "description": "Simple business card",
    "baseAnalyzerId": "prebuilt-document",
    "config": {"returnDetails": True},
    "fieldSchema": {
        "fields": {
            "ContactName": {
                "type": "string",
                "method": "extract",
                "description": "Name on business card"
            },
            "EmailAddress": {
                "type": "string",
                "method": "extract",
                "description": "Email address on business card"
            }
        }
    },
    "models": {
        "completion": "gpt-4.1",
        "embedding": "text-embedding-3-large"
    }
}

# Create the analyzer and wait for completion
poller = client.begin_create_analyzer(analyzer_name, body=analyzer_definition)
result = poller.result()
print(f"Analyzer created: {result.analyzer_id}")
```

#### Using the REST API to create an analyzer

Alternatively, you can use the REST API directly. The JSON data is submitted as a `PUT` request to the endpoint with the API key in the request header to start the analyzer creation operation. The response from the `PUT` request includes an **Operation-Location** in the header, which provides a *callback* URL that you can use to check on the status of the request by submitting a `GET` request.

```python
import json
import requests

# Get the business card schema
with open("card.json", "r") as file:
    schema_json = json.load(file)

# Use a PUT request to submit the schema for a new analyzer
analyzer_name = "business_card_analyser"

headers = {
    "Ocp-Apim-Subscription-Key": "<YOUR_API_KEY>",
    "Content-Type": "application/json"}

url = f"{<YOUR_ENDPOINT>}/contentunderstanding/analyzers/{analyzer_name}?api-version=2025-11-01"

response = requests.put(url, headers=headers, data=json.dumps(schema_json))

# Get the response and extract the ID assigned to the operation
callback_url = response.headers["Operation-Location"]

# Use a GET request to check the status of the operation
result_response = requests.get(callback_url, headers=headers)

# Keep polling until the operation is complete
status = result_response.json().get("status")
while status == "Running":
    result_response = requests.get(callback_url, headers=headers)
    status = result_response.json().get("status")

print("Done!")
```

### Analyze content

To analyze the contents of a file, you can use the Azure Content Understanding API to submit it to the endpoint. You can specify the content as a URL (for a file hosted in an Internet-accessible location) or upload binary file data directly (for example, a .pdf document, a .png image, an .mp3 audio file, or an .mp4 video file). The analysis request includes the analyzer to be used. Analysis is an asynchronous operation - after submitting the request, you receive an operation ID that you can use to check the status and retrieve the results when the operation is complete.

#### Using the Python SDK

The Python SDK for Content Understanding (`azure-ai-contentunderstanding`) provides a `ContentUnderstandingClient` class that simplifies interaction with the service. The SDK handles authentication, request formatting, and automatic polling for asynchronous operations.

```python
from azure.ai.contentunderstanding import ContentUnderstandingClient
from azure.ai.contentunderstanding.models import AnalysisInput
from azure.core.credentials import AzureKeyCredential

# Authenticate the client
endpoint = "<YOUR_ENDPOINT>"
credential = AzureKeyCredential("<YOUR_API_KEY>")
client = ContentUnderstandingClient(endpoint=endpoint, credential=credential)

# Analyze the business card using the custom analyzer
analyzer_name = "business_card_analyser"
poller = client.begin_analyze(
    analyzer_id=analyzer_name,
    inputs=[AnalysisInput(url="https://host.com/business-card.png")]
)

# Wait for the operation to complete and get the results
result = poller.result()

# Extract field values from the results
content = result.contents[0]
if content.fields:
    for field_name, field_data in content.fields.items():
        if field_data.type == "string":
            print(f"{field_name}: {field_data.value}")
```

>**Tip**: The SDK's `begin_analyze` method returns a poller object. Calling `.result()` on the poller automatically handles polling until the operation completes, so you don't need to write your own polling loop.

#### Using the REST API

You can also submit analysis requests directly by using the REST API. Your client application submits HTTP calls to the Content Understanding endpoint for your Microsoft Foundry resource, passing an API key in the header.

```python
import json
import requests

## Use a POST request to submit the file URL to the analyzer
analyzer_name = "business_card_analyser"

headers = {
        "Ocp-Apim-Subscription-Key": "<YOUR_API_KEY>",
        "Content-Type": "application/json"}

url = f"{<YOUR_ENDPOINT>}/contentunderstanding/analyzers/{analyzer_name}:analyze?api-version=2025-11-01"

request_body = {
    "inputs": [
        {
            "url": "https://host.com/business-card.png"
        }
    ]
}

response = requests.post(url, headers=headers, json=request_body)

# Get the response and extract the ID assigned to the analysis operation
response_json = response.json()
id_value = response_json.get("id")

# Use a GET request to check the status of the analysis operation
result_url = f"{<YOUR_ENDPOINT>}/contentunderstanding/analyzerResults/{id_value}?api-version=2025-11-01"

result_response = requests.get(result_url, headers=headers)

# Keep polling until the analysis is complete
status = result_response.json().get("status")
while status == "Running":
        result_response = requests.get(result_url, headers=headers)
        status = result_response.json().get("status")

# Get the analysis results
if status == "Succeeded":
    result_json = result_response.json()
```

>**Note**: You can specify a URL for the content file location as shown here. To submit binary file data directly, use the `analyzeBinary` operation instead.

#### Processing analysis results

The results depend on:

- The kind of content the analyzer is designed to analyze (for example, document, video, image, or audio).
- The schema for the analyzer.
- The contents of the file that was analyzed.

For example, the response from the *document*-based business card analyzer contains the extracted fields and the optical character recognition (OCR) layout of the document, including locations of lines of text, individual words, and paragraphs on each page.

**Using the Python SDK**: When using the SDK, the `AnalysisResult` object provides typed access to the results. The `contents` property contains a list of content objects, each with fields, markdown, and metadata:

```python
# (continued from previous SDK code example)

content = result.contents[0]
if content.fields:
    for field_name, field_data in content.fields.items():
        if field_data.type == "string":
            print(f"{field_name}: {field_data.value}")
```

**Using the REST API**: When using the REST API, the response is a JSON payload that your application must parse. An abbreviated example response for the business card analysis:

```json
{
    "id": "00000000-0000-0000-0000-a00000000000",
    "status": "Succeeded",
    "result": {
        "analyzerId": "biz_card_analyser_2",
        "apiVersion": "2025-11-01",
        "createdAt": "2025-05-16T03:51:46Z",
        "warnings": [],
        "contents": [
            {
                "markdown": "John Smith\nEmail: john@contoso.com\n",
                "fields": {
                    "ContactName": {
                        "type": "string",
                        "valueString": "John Smith",
                        "spans": [ { "offset": 0, "length": 10 } ],
                        "confidence": 0.994,
                        "source": "D(1,69,234,333,234,333,283,69,283)"
                    },
                    "EmailAddress": {
                        "type": "string",
                        "valueString": "john@contoso.com",
                        "spans": [ { "offset": 18, "length": 16 } ],
                        "confidence": 0.998,
                        "source": "D(1,179,309,458,309,458,341,179,341)"
                    }
                },
                "kind": "document",
                "startPageNumber": 1,
                "endPageNumber": 1,
                "unit": "pixel",
                "pages": [ { "pageNumber": 1, "width": 1000, "height": 620, "words": [ ... ], "lines": [ ... ] } ],
                "paragraphs": [ ... ],
                "sections": [ ... ]
            }
        ]
    }
}
```

Your application must typically parse the JSON to retrieve field values. For example, the following Python code extracts all of the *string* values:

```python
# (continued from previous code example)

# Iterate through the fields and extract the names and type-specific values
contents = result_json["result"]["contents"]
for content in contents:
    if "fields" in content:
        fields = content["fields"]
        for field_name, field_data in fields.items():
            if field_data['type'] == "string":
                print(f"{field_name}: {field_data['valueString']}")
```

The output from this code is shown here:

```
ContactName: John Smith
EmailAddress: john@contoso.com
```

## Extract data from documents with Document Intelligence
### Introduction

Forms and documents are used to communicate information in every industry, every day. Many organizations still manually extract data from forms to exchange information, whether it's filing claims, enrolling patients, processing receipts for expense reports, or reviewing operations data. Azure Document Intelligence is a cloud-based service in Microsoft Foundry that uses optical character recognition (OCR) and deep learning models to extract text, key-value pairs, tables, and structured data from forms and documents. It offers prebuilt models for common document types, document analysis models for general text extraction, and the ability to train custom models for your specific forms.

### What is Azure Document Intelligence?

**Azure Document Intelligence** is a cloud-based AI service in Microsoft Foundry that uses OCR and deep learning models to extract text, key-value pairs, selection marks, and tables from documents.

OCR captures document structure by creating bounding boxes around detected objects in an image. The locations of the bounding boxes are recorded as coordinates in relation to the rest of the page. Azure Document Intelligence returns bounding box data and other information in a structured JSON format that preserves the relationships from the original document.

To build a high-accuracy document extraction model from scratch requires deep learning expertise, large amounts of compute, and long training times. Azure Document Intelligence provides underlying models already trained on thousands of form examples, so you can achieve high-accuracy data extraction with minimal effort.

#### Document Intelligence service components

Azure Document Intelligence is composed of three categories of models:

- **Document analysis models**: Extract text, structure, tables, and selection marks from documents. The **read** model extracts text and detects languages, while the **layout** model adds table and structure extraction.
- **Prebuilt models**: Extract information from common document types - such as invoices, receipts, tax forms, ID documents, and more - without any training required.
- **Custom models**: Extract data from forms specific to your business using your own labeled datasets. Options include custom template models (fast and cost-effective for fixed layouts), custom neural models (higher accuracy for varying layouts), composed models, and custom classifiers.

#### Access Document Intelligence services

- **REST API**: Call the service directly using HTTP requests.
- **Client library SDKs**: Use SDKs for Python, C#, Java, and JavaScript.
- **Document Intelligence Studio**: An online tool for visually exploring, testing, and building Document Intelligence solutions.
- **Microsoft Foundry portal**: Integrate Document Intelligence with other Foundry tools.

#### Create a Document Intelligence resource

To use Azure Document Intelligence, you need an Azure resource. You can use either:

- A **Foundry resource**: A multi-service subscription that provides access to multiple AI services under a single endpoint and key.
- An **Azure Document Intelligence resource**: A single-service resource used only with Document Intelligence.

#### Input requirements

Azure Document Intelligence works on input documents that meet these requirements:

- Format must be JPEG, PNG, BMP, PDF (text or scanned), or TIFF. The read model also accepts Microsoft Office file formats.
- File size must be less than 500 MB for the standard tier and 4 MB for the free tier.
- Image dimensions must be between 50 x 50 pixels and 10,000 x 10,000 pixels.
- PDF documents must have dimensions less than 17 x 17 inches (A3 paper size).
- PDF documents must not be password-protected.

### Use the Document Intelligence Studio

The Azure Document Intelligence Studio is an online tool for visually exploring, understanding, and integrating features from the Document Intelligence service. You can use the Studio to analyze form layouts, extract data from prebuilt models, and train custom models - all through a visual interface. You can access the Studio at https://documentintelligence.ai.azure.com.

#### Studio capabilities

- **Document analysis models**: Test the read and layout models against your own documents to see extracted text, tables, and structure.
- **Prebuilt models**: Analyze documents using any available prebuilt model, such as invoices, receipts, ID documents, and tax forms.
- **Custom models**: Build, label, train, and test custom extraction models and custom classifiers.

#### Analyze documents with prebuilt models

1. Create an Azure Document Intelligence or Foundry Tools resource in the Azure portal.
2. Open the Document Intelligence Studio and select a prebuilt model (for example, Invoice, Receipt, or ID Document).
3. Provide your resource endpoint and key.
4. Upload or provide a URL to the document you want to analyze.
5. Review the extracted fields and their confidence scores.

#### Build custom model projects

You can use the Studio to handle the entire process of labeling, training, and testing custom models - without manually creating JSON files. The Studio generates the required `ocr.json`, `labels.json`, and `fields.json` files automatically. The high-level workflow is:

1. Create an Azure Document Intelligence or Foundry resource.
2. Upload at least 5-6 sample forms to an Azure Blob Storage container.
3. Configure cross-origin resource sharing (CORS) so the Studio can access your storage container.
4. Create a custom model project in the Studio, linking your storage container and Document Intelligence resource.
5. Label fields in your sample documents using the Studio's visual interface.
6. Train your model and review accuracy metrics.
7. Test the model against a new document that wasn't used during training.

#### Add-on capabilities

| Capability | Description |
| --- | --- |
| **High resolution extraction** | Extract text from high-resolution documents with greater accuracy. |
| **Formula extraction** | Detect and extract mathematical formulas from documents. |
| **Font property extraction** | Extract font information such as style, weight, and color. |
| **Barcode extraction** | Detect and read barcodes in documents. |
| **Searchable PDF** | Convert scanned documents into searchable PDF files. |
| **Query fields** | Use natural language queries to extract specific fields from documents. |
| **Key-value pairs** | Extract key-value pair relationships from documents using the layout model. |

### Use prebuilt models

Prebuilt models in Azure Document Intelligence enable you to extract data from common form types without training your own models. Microsoft trains these models on large numbers of sample documents, so you can expect accurate and reliable results for standard document types.

#### Document analysis models

**Read model**: The read model extracts printed and handwritten text from documents and images. It detects the language of each text line and classifies whether text is handwritten or printed. The read model is used as the foundation for text extraction in all other Document Intelligence models. For multi-page PDF or TIFF files, you can use the `pages` parameter in your request to specify a page range for analysis. The read model is ideal when you want to extract words and lines from documents with no fixed or predictable structure.

**Layout model**: The layout model extends the read model's text extraction with detection of selection marks, tables, and document structure information. It also supports an optional `keyValuePairs` feature to extract key-value pairs. When you digitize a document, it might be angled, or tables might have complex structures with merged cells or incomplete rows. The layout model can handle these difficulties. Each table cell is extracted with its content, bounding box position, and row/column indexes. Selection marks (checkboxes and radio buttons) are extracted with their bounding box, confidence level, and whether they're selected.

>**Note**: The *general document model* was available in earlier versions of Document Intelligence, but was deprecated in the `2023-10-31-preview` release. Its functionality for key-value pair and entity extraction has been incorporated into the layout model and other features.

#### Prebuilt models for specific document types

**Financial and legal documents**

| Model | Description |
| --- | --- |
| **Invoice** | Extracts customer name, vendor details, purchase order number, invoice and due dates, billing and shipping addresses, line items, and totals. |
| **Receipt** | Extracts merchant details, transaction date and time, line items, and totals. Supports single-page hotel receipt processing. |
| **Bank statement** | Extracts account information, beginning and ending balances, and transaction details. |
| **Check** | Extracts payee, amount, date, and other relevant information. |
| **Pay stub** | Extracts wages, hours, deductions, net pay, and other common pay stub fields. |
| **Credit card** | Extracts payment card information. |
| **Contract** | Extracts agreement and party details. |

**US tax documents**

| Model | Description |
| --- | --- |
| **Unified US tax** | A single model that extracts from any supported US tax form type. |
| **W-2** | Extracts taxable compensation details. |
| **1098** and variations | Extracts mortgage interest and related details. |
| **1099** and variations | Extracts income from various sources. |
| **1040** and variations | Extracts individual income tax return details. |

**US mortgage documents**

| Model | Description |
| --- | --- |
| **1003 (URLA)** | Extracts loan application details. |
| **1004 (URAR)** | Extracts information from property appraisals. |
| **1005** | Extracts validation-of-employment information. |
| **1008** | Extracts loan transmittal details. |
| **Closing disclosure** | Extracts final closing loan terms. |

**Personal identification documents**

| Model | Description |
| --- | --- |
| **ID document** | Extracts details from US driver's licenses, European Union IDs and driver's licenses, and international passports. Includes names, dates of birth, document numbers, and endorsements or restrictions. |
| **Health insurance card** | Extracts common fields from US health insurance cards. |
| **Marriage certificate** | Extracts certified marriage information. |

>**Important**: The ID document model extracts personal information covered by data protection laws in most jurisdictions. Ensure you have the individual's permission to store their data and that you comply with all applicable legal requirements.

#### Features of prebuilt models

- **Text extraction**: All prebuilt models extract lines and words from handwritten and printed text.
- **Key-value pairs**: Spans of text that identify a label and its response. For example, **Weight** and **31 kg**.
- **Selection marks**: Checkboxes and radio buttons, including whether they're selected or not.
- **Tables**: Data in cells, including the number of columns and rows, column and row headings, and merged cells.
- **Fields**: Models trained for a specific form type identify a fixed set of fields. For example, the invoice model extracts `CustomerName` and `InvoiceTotal`.

#### When to use prebuilt vs. custom models

Prebuilt models cover the most common document types. If you have an industry-specific or unique form type, you might get more accurate results with a custom model. However, custom models require time and sample data to train. Always check whether a prebuilt model exists for your scenario before investing in custom model development.

### Train and use custom models

When prebuilt models don't cover your specific document types, you can train custom models to extract data from your own forms. Azure Document Intelligence supports supervised machine learning, where you label sample documents with the fields you want to extract, and the service trains a model to recognize those fields in new documents.

#### Custom model types

**Custom template models**: Custom template models rely on a consistent visual template to extract labeled data. They work best for structured forms where the layout is static from one document instance to the next, such as questionnaires, applications, or standard government forms. Template models accurately extract labeled key-value pairs, selection marks, tables, regions, and signatures. Training takes only a few minutes, and more than 100 languages are supported.

**Custom neural models**: Custom neural models use deep learning and are fine-tuned on your labeled data. They combine layout and language features to extract fields from structured, semi-structured, and unstructured documents. Neural models support overlapping fields, signature detection, and table, row, and cell level confidence. Neural models deliver higher accuracy than template models, especially for semi-structured or unstructured documents where the layout varies between instances. However, they take longer to train and consume more resources.

**Choose between template and neural models**

| Factor | Custom template | Custom neural |
| --- | --- | --- |
| **Best for** | Structured forms with a consistent visual layout | Semi-structured or unstructured documents with varying layouts |
| **Training time** | Minutes | Longer (depends on dataset size) |
| **Training cost** | Lower | Higher |
| **Accuracy** | High for fixed-layout forms; decreases when layout varies | Higher overall, especially for documents with format variation |
| **Language support** | 100+ languages | Fewer languages |
| **Feature support** | Key-value pairs, selection marks, tables, regions, signatures | Overlapping fields, signature detection, table/row/cell confidence |

>**Tip**: Start with a custom template model if your forms have a consistent visual layout. It's faster and cheaper to train. If accuracy is insufficient or your documents vary in format, switch to a custom neural model.

**Custom classifiers**: Custom classification models identify the type of a document before invoking an extraction model. You can use a classifier to route incoming documents to the appropriate extraction model when you're handling multiple form types.

#### Train a custom model

To train a custom extraction model:

1. Store sample forms in an Azure blob container, along with JSON files containing layout and label field information:
    - An `ocr.json` file for each sample form (generated using the Analyze document function).
    - A single `fields.json` file describing the fields you want to extract.
    - A `labels.json` file for each sample form, mapping fields to their location in the form.
2. Generate a shared access signature (SAS) URL for the container.
3. Use the **Build model** REST API function or the equivalent SDK method.
4. Use the **Get model** REST API function to retrieve the trained model ID.

>**Tip**: Use at least five to six sample forms for training. A larger and more varied dataset produces more accurate models.

#### Use a custom model

To extract form data with a custom model, call the **Analyze document** function with your model ID. You can use either a supported SDK or the REST API.

**C#**

```csharp
string endpoint = "<endpoint>";
string apiKey = "<apiKey>";
AzureKeyCredential credential = new AzureKeyCredential(apiKey);
DocumentAnalysisClient client = new DocumentAnalysisClient(new Uri(endpoint), credential);

string modelId = "<modelId>";
Uri fileUri = new Uri("<fileUri>");

AnalyzeDocumentOperation operation = await client.AnalyzeDocumentFromUriAsync(WaitUntil.Completed, modelId, fileUri);
AnalyzeResult result = operation.Value;
```

**Python**

```python
endpoint = "YOUR_DOC_INTELLIGENCE_ENDPOINT"
key = "YOUR_DOC_INTELLIGENCE_KEY"

model_id = "YOUR_CUSTOM_BUILT_MODEL_ID"
formUrl = "YOUR_DOCUMENT"

document_analysis_client = DocumentAnalysisClient(
    endpoint=endpoint, credential=AzureKeyCredential(key)
)

task = document_analysis_client.begin_analyze_document_from_url(model_id, formUrl)
result = task.result()
```

A successful response contains an `analyzeResult` object with the extracted content and an array of pages containing information about the document.

#### Composed models

You can combine multiple custom models into a single **composed model**. When you submit a document to a composed model, Document Intelligence classifies it to determine the most appropriate component model, and then returns the extraction results from that model. This approach is useful when you handle multiple form types that each require their own extraction model.

## Implement knowledge mining with Azure AI Search
### Introduction

Azure AI Search is a powerful cloud-based service that enables you to extract, enrich, and explore information from a wide variety of data sources. It lets you connect to data sources and create indexes, understand how the indexing process works, and how AI skills can be used to enrich your data with insights such as language detection, key phrase extraction, and image analysis. You can query and filter results using full-text search, and use the knowledge store to persist enriched data for further analysis and integration with other systems.

### What is Azure AI Search?

Azure AI Search provides a cloud-based solution for indexing and querying a wide range of data sources, and creating comprehensive and high-scale search solutions. It provides the infrastructure and tools to create search solutions that extract data from structured, semi-structured, and non-structured documents and other data sources.

With Azure AI Search, you can:

- Index documents and data from a range of sources.
- Use AI skills to enrich index data.
- Store extracted insights in a knowledge store for analysis and integration.

Azure AI Search indexes contain insights extracted from your data, which can include text inferred or read using OCR from images, entities and key phrases detection through text analytics, and other derived information based on AI skills that are integrated into the indexing process.

Azure AI Search has many applications, including:

- Implementing an *enterprise search* solution to help employees or customers find information in websites or applications.
- Supporting *retrieval augmented generation* (RAG) in generative AI applications by using vector-based indexes for prompt grounding data.
- Creating *knowledge mining* solutions in which the indexing process is used to infer insights and extract granular data assets from documents to support data analytics.

### Extract data with an indexer

At the heart of Azure AI Search solutions is the creation of an *index*. An index contains your searchable content and is created and updated by an *indexer*.

The indexing process starts with a data source: the storage location of your original data artifacts; for example, an Azure blob store container full of documents, a database, or some other store. The indexer automates the extraction and indexing of data *fields* through an *enrichment pipeline*, in which it applies *document cracking* to extract the contents of the source documents and applies incremental steps to create a hierarchical (JSON-based) document with the required fields for the index definition. The result is a populated index, which can be queried to return specified fields from documents that match the query criteria.

#### How documents are constructed during indexing

The indexing process works by creating a document for each indexed entity. During indexing, an *enrichment pipeline* iteratively builds the documents that combine metadata from the data source with enriched fields extracted or generated by *skills*. You can think of each indexed document as a JSON structure, which initially consists of a document with the index fields mapped to fields extracted directly from the source data:

- **document**
    - **metadata_storage_name**
    - **metadata_author**
    - **content**

When the documents in the data source contain images, you can configure the indexer to extract the image data and place each image in a **normalized_images** collection:

- **document**
    - **metadata_storage_name**
    - **metadata_author**
    - **content**
    - **normalized_images**
        - **image0**
        - **image1**

Normalizing the image data in this way enables you to use the collection of images as an input for skills that extract information from image data. Each skill adds fields to the **document** - for example, a skill that detects the *language* in which a document is written might store its output in a **language** field. The document is structured hierarchically, and the skills are applied to a specific *context* within the hierarchy, enabling you to run the skill for each item at a particular level of the document. For example, you could run an optical character recognition (*OCR*) skill for each image in the normalized images collection to extract any text they contain:

- **document**
    - **metadata_storage_name**
    - **metadata_author**
    - **content**
    - **normalized_images**
        - **image0**
            - **Text**
        - **image1**
            - **Text**
    - **language**

The output fields from each skill can be used as inputs for other skills later in the pipeline, which in turn store *their* outputs in the document structure. For example, a *merge* skill could combine the original text content with the text extracted from each image to create a new **merged_content** field that contains all of the text in the document, including image text.

The fields in the final document structure at the end of the pipeline are mapped to index fields by the indexer in one of two ways:

- Fields extracted directly from the source data are all mapped to index fields. These mappings can be *implicit* (fields are automatically mapped to fields with the same name in the index) or *explicit* (a mapping is defined to match a source field to an index field, often to rename the field to something more useful or to apply a function to the data value as it is mapped).
- Output fields from the skills in the skillset are explicitly mapped from their hierarchical location in the output to the target field in the index.

### Enrich extracted data with AI skills

The enrichment pipeline that is orchestrated by an indexer uses a *skillset* of AI skills to create AI-enriched fields. The indexer applies each skill in order, refining the index document at each step.

#### Built-in skills

Azure AI Search provides a collection of *built-in* skills that you can include in a skillset for your indexer. Built-in skills include functionality from Foundry Tools such as Azure Vision and Azure Language, enabling you to apply enrichments such as:

- Detecting the language that text is written in.
- Detecting and extracting places, locations, and other entities in the text.
- Determining and extracting key phrases within a body of text.
- Translating text.
- Identifying and extracting (or removing) personally identifiable information (PII) within the text.
- Extracting text from images.
- Generating captions and tags to describe images.

To use the built-in skills, your indexer must have access to a Foundry Tools resource. You can use a restricted Azure AI Search resource that is included in Azure AI Search (and which is limited to indexing 20 or fewer documents) or you can attach a Foundry Tools resource in your Azure subscription (which must be in the same region as your Azure AI Search resource).

#### Custom skills

You can further extend the enrichment capabilities of your index by creating *custom* skills. Custom skills perform custom logic on input data from your index document to return new field values that can be incorporated into the index. Often, custom skills are "wrappers" around services that are specifically designed to extract data from documents. For example, you could implement a custom skill as an Azure Function, and use it to pass data from your index document to an Azure Document Intelligence model, which can extract fields from a form.

### Search an index

The index is the searchable result of the indexing process. It consists of a collection of JSON documents, with fields that contain the values extracted during indexing. Client applications can query the index to retrieve, filter, and sort information.

Each index field can be configured with the following attributes:

- **key**: Fields that define a unique key for index records.
- **searchable**: Fields that can be queried using full-text search.
- **filterable**: Fields that can be included in filter expressions to return only documents that match specified constraints.
- **sortable**: Fields that can be used to order the results.
- **facetable**: Fields that can be used to determine values for *facets* (user interface elements used to filter the results based on a list of known field values).
- **retrievable**: Fields that can be included in search results (by default, all fields are retrievable unless this attribute is explicitly removed).

#### Full-text search

While you could retrieve index entries based on simple field value matching, most search solutions use *full-text search* semantics to query an index. Full-text search queries in Azure AI Search are based on the *Lucene* query syntax, which provides a rich set of query operations for searching, filtering, and sorting data in indexes. Azure AI Search supports two variants of the Lucene syntax:

- **Simple** - An intuitive syntax that makes it easy to perform basic searches that match literal query terms submitted by a user.
- **Full** - An extended syntax that supports complex filtering, regular expressions, and other more sophisticated queries.

Some common parameters submitted with a query include:

- **search** - A search expression that includes the terms to be found.
- **queryType** - The Lucene syntax to be evaluated (*simple* or *full*).
- **searchFields** - The index fields to be searched.
- **select** - The fields to be included in the results.
- **searchMode** - Criteria for including results based on multiple search terms. For example, searching for *comfortable hotel* with a searchMode value of *Any* returns documents that contain "comfortable", "hotel", or both; while a searchMode value of *All* restricts results to documents that contain both "comfortable" and "hotel".

Query processing consists of four stages:

1. *Query parsing*. The search expression is evaluated and reconstructed as a tree of appropriate subqueries. Subqueries might include *term queries* (finding specific individual words - for example *hotel*), *phrase queries* (finding multi-term phrases specified in quotation marks - for example, *"free parking"*), and *prefix queries* (finding terms with a specified prefix - for example *air\**, which would match *airway*, *air-conditioning*, and *airport*).
2. *Lexical analysis* - The query terms are analyzed and refined based on linguistic rules. For example, text is converted to lower case and nonessential *stopwords* (such as "the", "a", "is", and so on) are removed. Then words are converted to their *root* form (for example, "comfortable" might be simplified to "comfort") and composite words are split into their constituent terms.
3. *Document retrieval* - The query terms are matched against the indexed terms, and the set of matching documents is identified.
4. *Scoring* - A relevance score is assigned to each result based on a term frequency/inverse document frequency (TF/IDF) calculation.

#### Filtering results

You can apply filters to queries in two ways:

- By including filter criteria in a *simple* **search** expression.
- By providing an OData filter expression as a **$filter** parameter with a *full* syntax search expression.

You can apply a filter to any *filterable* field in the index. For example, to find documents containing the text *London* that have an **author** field value of *Reviewer*, you can submit the following *simple* **search** expression:

```
search=London+author='Reviewer'
queryType=Simple
```

Alternatively, you can use an OData filter in a **$filter** parameter with a *full* Lucene search expression:

```
search=London
$filter=author eq 'Reviewer'
queryType=Full
```

>**Note**: OData **$filter** expressions are case-sensitive!

**Filtering with facets**: *Facets* are a useful way to present users with filtering criteria based on field values in a result set. They work best when a field has a small number of discrete values that can be displayed as links or options in the user interface. To use facets, you must specify *facetable* fields for which you want to retrieve the possible values in an initial query:

```
search=*
facet=author
```

The results include a collection of discrete facet values that you can display in the user interface. Then in a subsequent query, you can use the selected facet value to filter the results:

```
search=*
$filter=author eq 'selected-facet-value-here'
```

#### Sorting results

By default, results are sorted based on the relevancy score assigned by the query process, with the highest scoring matches listed first. However, you can override this sort order by including an OData **orderby** parameter that specifies one or more *sortable* fields and a sort order (*asc* or *desc*):

```
search=*
$orderby=last_modified desc
```

### Persist extracted information in a knowledge store

While the index might be considered the primary output from an indexing process, the enriched data it contains might also be useful in other ways. For example:

- Since the index is essentially a collection of JSON objects, each representing an indexed record, it might be useful to export the objects as JSON files for integration into a data orchestration process for extract, transform, and load (ETL) operations.
- You may want to normalize the index records into a relational schema of tables for analysis and reporting.
- Having extracted embedded images from documents during the indexing process, you might want to save those images as files.

Azure AI Search supports these scenarios by enabling you to define a *knowledge store* in the skillset that encapsulates your enrichment pipeline. The knowledge store consists of *projections* of the enriched data, which can be JSON objects, tables, or image files. When an indexer runs the pipeline to create or update an index, the projections are generated and persisted in the knowledge store.
