from dotenv import load_dotenv
import ollama
import os



def main():
    load_dotenv()  # loads .env into process environment

    llama_api_key = os.getenv("OLLAMA_API_KEY")
    if not llama_api_key:
        raise RuntimeError("Missing OLLAMA_API_KEY. Did you set it in .env?")

    ollama.client = ollama.Client(
    host="https://ollama.com",
    headers={'Authorization': 'Bearer ' + os.environ.get('OLLAMA_API_KEY')}
    )

    messages = [
        {
            'role': 'user',
            'content': 'Why is the sky blue?',
        },
    ]

    for part in ollama.client.chat('gpt-oss:120b', messages=messages, stream=True):
        print(part['message']['content'], end='', flush=True)


if __name__ == "__main__":
    main()
