import os
import anthropic
from openai import OpenAI
# import google.generativeai as genai
from dotenv import load_dotenv, find_dotenv

from config import *

load_dotenv(find_dotenv())

class HitAPI:
    def __init__(self) -> None:
        OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
        CLAUDE_API_KEY = os.environ.get("CLAUDE_API_KEY")
        # GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

        self.client_gpt = OpenAI(api_key=OPENAI_API_KEY)
        self.client_claude = anthropic.Client(api_key=CLAUDE_API_KEY)

        # # genai.configure(api_key=GEMINI_API_KEY)
        # # self.client_gemini = genai.GenerativeModel(
        #                                 'gemini-pro',
        #                                 generation_config=genai.GenerationConfig(
        #                                 max_output_tokens=8000,
        #                                 temperature=0.9), ## commenting to remove the error
        #                                 safety_settings=safety_settings
        #                             )

    def hit_claude(self, prompt, prompt_header):
        response = self.client_claude.messages.create(
            model="claude-3-opus-20240229",
            max_tokens = 4000,
            system=prompt_header, # <-- system prompt
            messages=[
                {"role": "user", "content": prompt} # <-- user prompt
            ]
        )

        return response.content[0].text

    def hit_gpt(self, prompt, prompt_header):
        completion = self.client_gpt.chat.completions.create(
        seed=42,
        model="gpt-4-turbo-preview",
        messages=[
            {"role": "system", "content": prompt_header},
            {"role": "user", "content": prompt}
        ]
        )

        return completion.choices[0].message.content

    def hit_gemini(self, prompt, prompt_header):
        prompt=prompt_header + '\n\n' + prompt
        response = self.client_gemini.generate_content(prompt)
        specific_answer = response.candidates[0].content.parts[0].text
        
        return specific_answer