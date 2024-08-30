# Simple Markdown Translator

Translate Markdown documents to your desired language conveniently using Docker and stdin pipes!

## Usage

```bash
cat examples/latex-url.md | ./md-translate.sh | tee output.md
```

### With Docker

```bash
cat examples/latex-url.md | docker run --rm -i -e OPENAI_API_KEY quay.io/ulagbulag/md-translate:latest
```

## Configuration

- **OPENAI_API_KEY**: See how to get API Key: https://help.openai.com/en/articles/7039783-how-can-i-access-the-chatgpt-api

## Features

- **TeX Live** markdown plugin support

## License

Please check the [LICENSE](/LICENSE) file.

### External Resources

- `examples`: Licenses are specified separately for each resource
- `prompt.md`: Derived from https://github.com/smikitky/chatgpt-md-translator (MIT)
