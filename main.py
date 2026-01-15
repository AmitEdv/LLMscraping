from scrapegraphai.graphs import SmartScraperGraph
import pandas as pd
import os

graph_config = {
    "llm": {
        "model": "ollama/phi3:mini",
        "model_tokens":"8192",
        "format": "json",
        "base_url": "http://localhost:11434",
    },
    "embedding": {
        "model": "ollama/nomic-embed-text", 
        "base_url": "http://localhost:11434",
    },
    "verbose": True,
    "headless": False,
}

smart_scraper = SmartScraperGraph(
    prompt=f"""
    Hello! Tell me the title of the topic in the source
    """,
    source="https://en.wikipedia.org/wiki/Alpaca",
    config=graph_config
    )

result = smart_scraper.run()
print(result)