# Develop natural language solutions in Azure
## Analyze text with Azure Language in Foundry Tools
### Introduction

Every day, the world generates a vast quantity of data; much of it text-based in the form of emails, social media posts, online reviews, business documents, and more. Artificial intelligence techniques that apply statistical and semantic models enable you to create applications that extract meaning and insights from this text-based data.

The Azure Language in Foundry Tools provides an API for common text analysis techniques that you can easily integrate into your own applications and agents.

### Azure Language in Microsoft Foundry Tools

Azure Language in Foundry Tools is designed to help you extract information from text. It provides functionality that you can use for tasks like:

- *Language detection* - determining the language in which text is written.
- *Named entity recognition* - detecting references to entities, including people, locations, time periods, organizations, and more.
- *Personally Identifiable Information (PII) extraction* - identifying and redacting personal details in text.

<img width="662" height="507" alt="image" src="https://github.com/user-attachments/assets/8b27390f-3f20-4d41-9251-80a514ff5ceb" />

>**Note**: Azure Language also provides functionality for sentiment analysis, summarization, key phrase extraction, and other common language-related tasks. These deprecated capabilities are provided to support existing applications.

#### Using a Microsoft Foundry resource for text analysis

To use Azure Language in Foundry Tools to analyze text, you must provision a Microsoft Foundry resource in your Azure subscription.

After you have provisioned a Foundry resource in your Azure subscription, you can use its **endpoint** to call the Azure Language APIs from your code, authenticating requests by either providing the **key** associated with your resource or by using a Microsoft Entra ID identity.

#### Authentication

To authenticate using *key-based* authentication, use the key associated with your Foundry resource.

```python
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient

credential = AzureKeyCredential("YOUR_FOUNDRY_RESOURCE_KEY")
client = TextAnalyticsClient(endpoint="YOUR_FOUNDRY_RESOURCE_ENDPOINT", 
                             credential=credential)
```

For greater security in production solutions, Microsoft recommends using Microsoft Entra ID authentication:

```python
from azure.identity import DefaultAzureCredential
from azure.ai.textanalytics import TextAnalyticsClient

credential = DefaultAzureCredential()
client = TextAnalyticsClient(endpoint="YOUR_FOUNDRY_RESOURCE_ENDPOINT", 
                             credential=credential)
```

### Detect language

The Azure Language detection API evaluates text input and, for each document submitted, returns language identifiers with a score indicating the strength of the analysis.

This capability is useful for content stores that collect arbitrary text, where language is unknown. Another scenario could involve a chat application. If a user starts a session with the application, language detection can be used to determine which language they're using and allow you to configure your application's responses in the appropriate language.

The document size must be under 5,120 characters. The size limit is per document and each collection is restricted to 1,000 items (IDs).

```python
documents = ["Hello World!", "Bonjour le monde!"]

response = client.detect_language(documents=documents)
for doc in response:
    print(f"Document: {doc.id}")
    print(f"\tPrimary Language: {doc.primary_language.name}")
    print(f"\tISO6391 Name: {doc.primary_language.iso6391_name}")
    print(f"\tConfidence Score: {doc.primary_language.confidence_score}")
```

```output
Document: 0
        Primary Language: English
        ISO6391 Name: en
        Confidence Score: 0.9
Document: 1
        Primary Language: French
        ISO6391 Name: fr
        Confidence Score: 0.98
```

If you try to detect the language of a document that has multilingual content, the response may reflect some ambiguity. Mixed language content within the same document returns the language with the largest representation in the content, but with a lower positive rating.

When there's ambiguity as to the language content (e.g. character encoding issues), the response for the language name and ISO code will be returned as `(unknown)` and the score value will be returned as `0`.

### Extract entities

Named Entity Recognition identifies entities that are mentioned in the text. Entities are grouped into categories and subcategories, for example:

- Person
- Location
- DateTime
- Organization
- Address
- Email
- URL

```python
documents = ["Microsoft was founded on April 4, 1975 by Bill Gates and Paul Allen in Albuquerque, New Mexico.",
             "Satya Nadella became CEO of Microsoft on February 4, 2014."]

response = client.recognize_entities(documents=documents)
for doc in response:
    print(f"Entities in document {doc.id}:")
    for entity in doc.entities:
        print(f" - {entity.text} ({entity.category})")
```

```output
Entities in document 0:
 - Microsoft (Organization)
 - April 4, 1975 (DateTime)
 - Bill Gates (Person)
 - Paul Allen (Person)
 - Albuquerque (Location)
 - New Mexico (Location)
Entities in document 1:
 - Satya Nadella (Person)
 - CEO (PersonType)
 - Microsoft (Organization)
 - February 4, 2014. (DateTime)
```

### Extract personally identifiable information (PII)

Azure Language provides PII detection and redaction capabilities to identify sensitive information such as names, addresses, phone numbers, email addresses, social security numbers, and credit card numbers. You can both extract PII entities for analysis and redact (mask) them to protect privacy.

```python
documents = ["John Smith works at Contoso Ltd. His email is john.smith@contoso.com and his phone number is 555-012-456.",
             "Patient Sarah Johnson, SSN 123-45-6789, was admitted on 03/15/2024."]

response = client.recognize_pii_entities(documents=documents, language="en")
for doc in response:
    print(f"\nPII entities in document {doc.id}:")
    for entity in doc.entities:
        print(f" - {entity.text}: {entity.category} (confidence: {entity.confidence_score:.2f})")
```

```output
PII entities in document 0:
 - John Smith: Person (confidence: 0.99)
 - Contoso Ltd: Organization (confidence: 0.85)
 - john.smith@contoso.com: Email (confidence: 1.00)
 - 555-012-456: PhoneNumber (confidence: 0.80)
PII entities in document 1:
 - Sarah Johnson: Person (confidence: 0.99)
 - 123-45-6789: USSocialSecurityNumber (confidence: 0.99)
 - 03/15/2024: DateTime (confidence: 0.80)
```

You can also redact the PII entities to protect sensitive information:

```python
response = client.recognize_pii_entities(documents=documents, language="en")
for doc in response:
    print(f"\nDocument {doc.id} (redacted):")
    print(f" {doc.redacted_text}")
```

```output
Document 0 (redacted):
 ********** works at ************. His email is ************************ and his phone number is ********.
Document 1 (redacted):
 Patient *************, SSN ***********, was admitted on **********.
```

## Develop a text analysis agent with the Azure Language MCP server
### Introduction

The Azure Language MCP server connects AI agents to Azure Language services through the **Model Context Protocol (MCP)**.

### What is the Model Context Protocol?

The Model Context Protocol (MCP) is an open protocol that defines how AI agents interact with external tools, data sources, and services. MCP uses a client-server architecture with the following components:

- **Host**: The application that runs the agent (such as Microsoft Foundry or a custom app).
- **Client**: A component within the host that manages connections to MCP servers and handles communication.
- **Server**: A program that exposes tools, resources, and prompts that an agent can discover and call.

When an agent connects to an MCP server, it receives a catalog of available tools along with descriptions of what each tool does. The agent can then choose the right tool based on the user's request. This approach is called *dynamic tool discovery* - the agent doesn't need hardcoded knowledge of each tool. Instead, it queries the MCP server at runtime to find out what's available.

The key advantage of MCP for AI agents is flexibility. Tools can be added, updated, or removed on the server without modifying the agent itself.

### Azure Language MCP server capabilities

The Azure Language MCP server exposes Azure Language NLP capabilities as tools that any MCP-compatible agent can call:

| Capability | Description |
| --- | --- |
| **Language Detection** | Identifies the language in which text is written. |
| **Named Entity Recognition** | Identifies and categorizes entities in text, such as people, places, organizations, dates, and quantities. |
| **PII Redaction** | Detects and redacts personally identifiable information (PII) such as names, addresses, and phone numbers. |
| **Text Analytics for Health** | Extracts and labels medical entities (such as diagnoses, medications, and symptoms) from clinical text. |

### How the agent selects tools

1. The user sends a prompt to the agent.
2. The agent analyzes the prompt and determines which task (or tasks) need to be performed.
3. The agent checks the available MCP tools and their descriptions to find the best match.
4. The agent calls the selected tool through the MCP server, passing the relevant input text.
5. The MCP server processes the request using the appropriate Azure Language capability and returns the results.
6. The agent combines the results into a natural language response for the user.

### MCP server endpoint

The Azure Language MCP server is available as a remote endpoint with the following URL format:

```
https://{foundry-resource-name}.cognitiveservices.azure.com/language/mcp?api-version=2025-11-15-preview
```

### Connect and use the Language MCP server with an agent

#### Create a Foundry project and agent

1. In the Microsoft Foundry portal, create a new project (or use an existing one).
2. Deploy a model (such as **gpt-4.1**) that your agent will use for reasoning and generating responses.
3. Create an agent and give it instructions that describe its purpose.

#### Connect the Azure Language MCP server

1. In the navigation pane, select the **Tools** page.
2. Select **Connect a tool** and choose **Azure Language in Foundry Tools** from the catalog.
3. Configure the connection with:
    - **Foundry resource name**: The name of your Foundry resource.
    - **Authentication**: Key-based.
    - **Credential** (`Ocp-Apim-Subscription-Key`): The key for your Foundry project.
4. Wait for the connection to be created, then select **Use in an agent** and choose your agent.

#### Build a client application

The Microsoft Foundry SDK supports programmatic access through the OpenAI Responses API:

```python
response = openai_client.responses.create(
    input=[{"role": "user", "content": user_prompt}],
    extra_body={
        "agent_reference": {
            "name": "Text-Analysis-Agent",
            "type": "agent_reference"
        }
    },
)

print(response.output_text)
```

#### Connect the MCP server in code

You can define the MCP tool connection directly in code using the `MCPTool` class:

```python
from azure.ai.projects.models import MCPTool

mcp_tool = MCPTool(
    server_label="azure-language",
    server_url="https://{foundry-resource-name}.cognitiveservices.azure.com/language/mcp?api-version=2025-11-15-preview",
    require_approval="always",
)
```

## Develop a speech-capable generative AI application
### Introduction

A voice carries meaning beyond words. Microsoft Foundry provides generative AI models that can transcribe and synthesize speech.

### Choose a speech-capable model

Microsoft Foundry Models includes generative AI models from multiple providers with different capabilities. When it comes to speech-capable models, there are two common use-cases:

- Generative AI models that can transcribe speech to text.
- Generative AI models that can synthesize text to speech.

Microsoft Foundry provides models that support both, including specialized speech-capable models from the **gpt-4o** family.

### Transcribe speech

Speech transcription, or *speech-to-text*, involves submitting audio content to a model, which responds with a text-based transcript.

Models that support speech-to-text:

- **gpt-4o-transcribe**
- **gpt-4o-mini-transcribe**
- **gpt-4o-transcribe-diarize**

```python
from openai import AzureOpenAI
from pathlib import Path

client = AzureOpenAI(
    azure_endpoint=YOUR_FOUNDRY_ENDPOINT,
    api_key=YOUR_FOUNDRY_KEY,
    api_version="2025-03-01-preview"
)

file_path = Path("speech.mp3")
audio_file = open(file_path, "rb")

transcription = client.audio.transcriptions.create(
    model=YOUR_MODEL_DEPLOYMENT,
    file=audio_file,
    response_format="text"
)

print(transcription)
```

### Synthesize speech

Speech synthesis, or *text-to-speech*, involves submitting text to a model, which returns an audio stream of the vocalized text.

Models that support text-to-speech:

- **gpt-4o-tts**
- **gpt-4o-mini-tts**

```python
from openai import AzureOpenAI
from pathlib import Path

client = AzureOpenAI(
    azure_endpoint=YOUR_FOUNDRY_ENDPOINT,
    api_key=YOUR_FOUNDRY_KEY,
    api_version="2025-03-01-preview"
)

speech_file_path = Path("output_speech.wav")

with client.audio.speech.with_streaming_response.create(
            model=YOUR_MODEL_DEPLOYMENT,
            voice="alloy",
            input="This speech was AI-generated!",
            instructions="Speak in an upbeat, excited tone.",
    ) as response:
    response.stream_to_file(speech_file_path)

print(f"Speech generated and saved to {speech_file_path}")
```

## Create speech-enabled apps with Azure Speech in Microsoft Foundry Tools
### Introduction

Azure Speech in Microsoft Foundry Tools enables you to build speech-enabled applications. This module focuses on using the speech-to-text and text to speech APIs, which enable you to create apps that are capable of speech recognition and speech synthesis.

### Use the Speech to Text API

Azure Speech in Foundry Tools supports speech recognition through the *Speech to text* API. The consistent pattern is:

1. Use a **SpeechConfig** object to encapsulate the information required to connect to your Foundry resource (its **endpoint** or **region** and **key**).
2. Optionally, use an **AudioConfig** to define the input source for the audio to be transcribed. By default, this is the default system microphone, but you can also specify an audio file.
3. Use the **SpeechConfig** and **AudioConfig** to create a **SpeechRecognizer** object.
4. Use the methods of the **SpeechRecognizer** object to call the underlying API functions. For example, **RecognizeOnceAsync()** asynchronously transcribes a single spoken utterance.
5. Process the response - a **SpeechRecognitionResult** object with properties:
    - Duration
    - OffsetInTicks
    - Properties
    - Reason
    - ResultId
    - Text

If successful, the **Reason** property has the enumerated value **RecognizedSpeech**, and the **Text** property contains the transcription. Other possible values include **NoMatch** or **Canceled**.

```python
import azure.cognitiveservices.speech as speech_sdk

speech_config = speech_sdk.SpeechConfig(subscription="YOUR_FOUNDRY_KEY",
                                       endpoint="YOUR_FOUNDRY_ENDPOINT")

file_path = "audio.wav"
audio_config = speech_sdk.audio.AudioConfig(filename=file_path)

speech_recognizer = speech_sdk.SpeechRecognizer(speech_config=speech_config,
                                               audio_config=audio_config)

result = speech_recognizer.recognize_once_async().get()

if result.reason == speech_sdk.ResultReason.RecognizedSpeech:
    print(f"Transcription:\n{result.text}")
else:
    print("Error transcribing message: {}".format(result.reason))
```

### Use the Text to Speech API

The pattern for speech synthesis is similar to speech recognition:

1. Use a **SpeechConfig** object to encapsulate connection information.
2. Optionally, use an **AudioConfig** to define the output device (default is the system speaker; you can specify a file or process the audio stream directly).
3. Use **SpeechConfig** and **AudioConfig** to create a **SpeechSynthesizer** object.
4. Use **SpeakTextAsync()** to convert text to spoken audio.
5. Process the response - a **SpeechSynthesisResult** with properties: AudioData, Properties, Reason, ResultId.

```python
import azure.cognitiveservices.speech as speechsdk

speech_config = speechsdk.SpeechConfig(subscription=KEY, endpoint=ENDPOINT)
audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True)

speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config,
                                                 audio_config=audio_config)
text = "My voice is my password!"
speech_synthesis_result = speech_synthesizer.speak_text_async(text).get()

if speech_synthesis_result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
    print("Speech synthesized for text [{}]".format(text))
elif speech_synthesis_result.reason == speechsdk.ResultReason.Canceled:
    cancellation_details = speech_synthesis_result.cancellation_details
    print("Speech synthesis canceled: {}".format(cancellation_details.reason))
    if cancellation_details.reason == speechsdk.CancellationReason.Error:
        if cancellation_details.error_details:
            print("Error details: {}".format(cancellation_details.error_details))
```

### Configure audio format and voices

#### Audio format

Azure Speech supports multiple output formats for the audio stream. You can choose based on audio file type, sample-rate, and bit-depth:

```python
speech_config.set_speech_synthesis_output_format(SpeechSynthesisOutputFormat.Riff24Khz16BitMonoPcm)
```

#### Voices

The Azure Speech service provides multiple voices identified by names indicating a locale and person's name:

```python
speech_config.speech_synthesis_voice_name='en-US-Brian:DragonHDLatestNeural'
```

### Use Speech Synthesis Markup Language

The service supports **Speech Synthesis Markup Language** (SSML), an XML-based syntax for controlling speech output characteristics:

- Specify a speaking style (e.g. "excited" or "cheerful")
- Insert pauses or silence
- Specify *phonemes* (phonetic pronunciations)
- Adjust *prosody* (pitch, timbre, speaking rate)
- Use "say-as" rules (date, time, telephone number)
- Insert recorded speech or audio

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" 
                     xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="en-US"> 
    <voice name="en-US-AriaNeural"> 
        <mstts:express-as style="cheerful"> 
          I say tomato 
        </mstts:express-as> 
    </voice> 
    <voice name="en-US-GuyNeural"> 
        I say <phoneme alphabet="sapi" ph="t ao m ae t ow"> tomato </phoneme>. 
        <break strength="weak"/>Lets call the whole thing off! 
    </voice> 
</speak>
```

To submit SSML:

```python
speech_synthesis_result = speech_synthesizer.speak_ssml_async('<speak>...').get()
```

## Develop a speech agent with the Azure Speech MCP server
### Introduction

The Azure Speech MCP server connects AI agents to Azure Speech in Foundry Tools through MCP.

### Azure Speech MCP server capabilities

The Azure Speech MCP server exposes two core speech capabilities as tools:

| Capability | Description |
| --- | --- |
| **Speech-to-text (Recognize)** | Converts audio files to text. Supports WAV, MP3, OGG, FLAC, MP4, M4A, AAC and others. Includes options for language selection, phrase hints, profanity filtering, and output formats. |
| **Text-to-speech (Synthesize)** | Converts text into natural-sounding audio files using neural voices. Supports multiple languages and voices, generates output in WAV, MP3, or other formats. |

### Storage requirements

Unlike text-only MCP tools, the Azure Speech MCP server works with audio files and requires an **Azure Storage account**.

- **Text-to-speech**: The server saves generated audio files to Azure Blob Storage. The agent's response includes a link to the generated file.
- **Speech-to-text**: The agent can transcribe audio files from a publicly accessible URL or from Azure Blob Storage accessed with a SAS URL.

When connecting the Speech MCP server, you provide a **SAS URL** for a blob container granting read/write permissions.

### MCP server endpoint

```
https://{foundry-resource-name}.cognitiveservices.azure.com/speech/mcp?api-version=2025-11-15-preview
```

## Develop an Azure Speech Voice Live Agent in Microsoft Foundry
### Introduction

The Voice Live API enables developers to create voice-enabled applications with real-time, bidirectional communication using WebSocket connections.

### Key features of the Voice Live API

- Real-time audio processing with support for multiple formats (PCM16, G.711)
- Advanced voice options, including OpenAI voices and Azure custom voices
- Avatar integration using WebRTC for video and animation
- Built-in noise reduction and echo cancellation
- JSON-formatted events manage conversations, audio streams, and responses

### WebSocket endpoint

- **Project connection:** `wss://<your-ai-foundry-resource-name>.services.ai.azure.com/voice-live/realtime?api-version=2025-10-01`
- **Model connection:** `wss://<your-ai-foundry-resource-name>.cognitiveservices.azure.com/voice-live/realtime?api-version=2025-10-01`

### Voice Live API events

Client events:
- `session.update`: Modify session configurations.
- `input_audio_buffer.append`: Add audio data to the buffer.
- `response.create`: Generate responses via model inference.

Server events:
- `session.updated`: Confirm session configuration changes.
- `response.done`: Indicate response generation completion.
- `conversation.item.created`: Notify when a new conversation item is added.

### Configure session settings

```json
{
  "type": "session.update",
  "session": {
    "modalities": ["text", "audio"],
    "voice": {
      "type": "openai",
      "name": "alloy"
    },
    "instructions": "You are a helpful assistant. Be concise and friendly.",
    "input_audio_format": "pcm16",
    "output_audio_format": "pcm16",
    "input_audio_sampling_rate": 24000,
    "turn_detection": {
      "type": "azure_semantic_vad",
      "threshold": 0.5,
      "prefix_padding_ms": 300,
      "silence_duration_ms": 500
    },
    "temperature": 0.8,
    "max_response_output_tokens": "inf"
  }
}
```

>**Tip**: Use Azure semantic VAD for intelligent turn detection and improved conversational flow.

### Real-time audio processing

- **Append audio:** Add audio bytes to the input buffer.
- **Commit audio:** Process the audio buffer for transcription or response generation.
- **Clear audio:** Remove audio data from the buffer.

Noise reduction and echo cancellation configuration:

```json
{
  "type": "session.update",
  "session": {
    "input_audio_noise_reduction": {
      "type": "azure_deep_noise_suppression"
    },
    "input_audio_echo_cancellation": {
      "type": "server_echo_cancellation"
    }
  }
}
```

### Avatar streaming

The Voice Live API supports WebRTC-based avatar streaming. Use the `session.avatar.connect` event to provide the client's SDP offer and configure video resolution, bitrate, codec settings, and animation outputs (blendshapes, visemes).

## Translate text and speech with Microsoft Foundry Tools
### Introduction

Microsoft Foundry provides support for translation through Foundry Tools:

- **Azure Translator in Foundry Tools**: A comprehensive translation service for text, with a wide range of supported languages and the ability to create custom translation models.
- **Azure Speech in Foundry Tools**: A suite of speech-related tools, including speech-to-text and speech-to-speech translation in multiple languages simultaneously.

### Translate text

Azure Translator in Foundry Tools provides an API for translating text between over 90 supported languages. With Azure Translator you can:

- Translate or transliterate text using the default translation model or a large language model (LLM).
- Translate documents, synchronously or asynchronously, while maintaining document structure.
- Use custom translation models to translate domain-specific terms.

#### Connect to an Azure Translator resource

The endpoint can be:
- The Azure Translator *global* endpoint: `api.cognitive.microsofttranslator.com`
- Azure Translator *regional* endpoints: `api-nam.cognitive.microsofttranslator.com`, `api-apc.cognitive.microsofttranslator.com`, `api-eur.cognitive.microsofttranslator.com`
- Foundry resource endpoints: `{foundry-resource-name}.cognitiveservices.azure.com/`

```python
from azure.core.credentials import AzureKeyCredential
from azure.ai.translation.text import *

key_credential = AzureKeyCredential("FOUNDRY_KEY")

# Connect to a Foundry resource endpoint
client = TextTranslationClient(credential=key_credential, endpoint="FOUNDRY_ENDPOINT")

# Or connect using a region
client = TextTranslationClient(credential=key_credential, region="FOUNDRY_REGION")
```

#### Determine available languages

```python
languages = client.get_supported_languages(scope="translation")
print("{} languages supported:".format(len(languages.translation)))
for language in languages.translation.keys():
    print(languages.translation[language].name + " (" + language + ")")
```

#### Translate text

Source text is passed as a list of **InputTextItem** objects. You can optionally specify a **from_language** parameter or let Azure Translator auto-detect the source. Target languages are specified as a list of language codes in the **to_language** parameter.

```python
input_text_elements = [InputTextItem(text="Hola"), InputTextItem(text="こんにちは")]
translation_results = client.translate(body=input_text_elements, to_language=["fr", "en"])
idx = 0
for translation in translation_results:
    input_text = input_text_elements[idx].text
    idx += 1
    sourceLanguage = translation.detected_language
    for translated_text in translation.translations:
        print(f"'{input_text}' was translated from {sourceLanguage.language} to {translated_text.to} as '{translated_text.text}'.")
```

```output
'Hola' was translated from es to fr as 'Bonjour'.
'Hola' was translated from es to en as 'Hello'.
'こんにちは' was translated from ja to fr as 'Bonjour'.
'こんにちは' was translated from ja to en as 'Hello'.
```

#### Transliterate text

You can transliterate text to a different script rather than translating to a different language:

```python
source_text = "こんにちは"
input_text_elements = [InputTextItem(text=source_text)]
transliteration_results = client.transliterate(body=input_text_elements, language="ja",
                                               from_script="Jpan", to_script="Latn")
for transliteration in transliteration_results:
    sourceScript = transliteration.script
    targetScript = transliteration.text
    print(f"'{source_text}' was transliterated into {sourceScript} as {targetScript}.")
```

```output
'こんにちは' was transliterated into Latn as Kon'nichiwa.
```

### Translate speech

Azure Speech provides a Speech Translation API that enables you to build solutions that translate spoken input and return the translation as text or speech.

#### Connect to an Azure Speech resource

```python
import azure.cognitiveservices.speech as speech_sdk

translation_cfg = speech_sdk.translation.SpeechTranslationConfig(
                    subscription="FOUNDRY_KEY", endpoint="FOUNDRY_ENDPOINT")
```

#### Configure translation languages and input

```python
translation_cfg.speech_recognition_language = 'en-US'
translation_cfg.add_target_language('fr')
translation_cfg.add_target_language('ja')
print('Ready to translate from',translation_cfg.speech_recognition_language)

audio_cfg = speech_sdk.AudioConfig(use_default_microphone=True)
```

#### Translate speech to text

```python
translator = speech_sdk.translation.TranslationRecognizer(translation_config=translation_cfg,
                                                          audio_config=audio_cfg)
print("Speak now...")
translation_results = translator.recognize_once_async().get()
print(f"Translating '{translation_results.text}'")

translations = translation_results.translations
for translation_language in translations:
    print(f"{translation_language}: '{translations[translation_language]}'")
```

```output
Speak now...
Translating 'Hello.'
fr: 'Bonjour.'
ja: 'こんにちは。'
```

#### Synthesize translations as speech

##### Manual synthesis

Combine two separate operations:
1. Use a **TranslationRecognizer** to translate spoken input into text transcriptions.
2. Iterate through the **Translations**, using a **SpeechSynthesizer** to synthesize audio for each language.

```python
import azure.cognitiveservices.speech as speech_sdk

# Configure translation
translation_cfg = speech_sdk.translation.SpeechTranslationConfig(subscription="FOUNDRY_KEY",
                                                                 endpoint="FOUNDRY_ENDPOINT")
translation_cfg.speech_recognition_language = 'en-US'
translation_cfg.add_target_language('fr')
translation_cfg.add_target_language('ja')
audio_cfg = speech_sdk.AudioConfig(use_default_microphone=True)

# Configure speech synthesis
speech_cfg = speech_sdk.SpeechConfig(subscription="FOUNDRY_KEY", 
                                     endpoint="FOUNDRY_ENDPOINT")
audio_out_cfg = speech_sdk.audio.AudioOutputConfig(use_default_speaker=True)
voices = {
        "fr": "fr-FR-HenriNeural",
        "ja": "ja-JP-NanamiNeural"
}

# Get translations
translator = speech_sdk.translation.TranslationRecognizer(translation_config=translation_cfg,
                                                          audio_config=audio_cfg)
print("Speak now...")
translation_results = translator.recognize_once_async().get()
print(f"Translating '{translation_results.text}'")

translations = translation_results.translations
for translation_language in translations:
    print(f"{translation_language}: '{translations[translation_language]}'")
    speech_cfg.speech_synthesis_voice_name = voices.get(translation_language)
    speech_synthesizer = speech_sdk.SpeechSynthesizer(speech_cfg, audio_out_cfg)
    speak = speech_synthesizer.speak_text_async(translations[translation_language]).get()
    if speak.reason != speech_sdk.ResultReason.SynthesizingAudioCompleted:
        print(speak.reason)
```

##### Event-based synthesis

For 1:1 translation (one source language into one target language), you can use event-based synthesis to capture the translated audio as a stream:

- Specify the desired voice in the **TranslationConfig**.
- Create an event handler for the **TranslationRecognizer** object's **Synthesizing** event.
- In the event handler, use **GetAudio()** to retrieve the byte stream of translated audio.

>**Note**: You can't use event-based synthesis for multi-language translation.

```python
import azure.cognitiveservices.speech as speech_sdk
from playsound3 import playsound

source_language, target_language = "en-US", "fr"
output_file = "translation.wav"
translation_cfg = speech_sdk.translation.SpeechTranslationConfig(subscription="FOUNDRY_KEY",
                                                                 endpoint="FOUNDRY_ENDPOINT")
translation_cfg.speech_recognition_language = source_language
translation_cfg.add_target_language(target_language)
translation_cfg.voice_name = "fr-FR-HenriNeural"
audio_cfg = speech_sdk.AudioConfig(use_default_microphone=True)
translator = speech_sdk.translation.TranslationRecognizer(translation_config=translation_cfg,
                                                          audio_config=audio_cfg)

def synthesis_callback(evt):
    size = len(evt.result.audio)
    print(f'Audio synthesized: {size} byte(s) {"(COMPLETED)" if size == 0 else ""}')
    if size > 0:
        file = open(output_file, 'wb+')
        file.write(evt.result.audio)
        file.close()

translator.synthesizing.connect(synthesis_callback)

print(f"Speak now (in {source_language})...")
translation_results = translator.recognize_once()
print(f"Translating '{translation_results.text}'")

print(translation_results.translations[target_language])
playsound(output_file)
```
