# AI Model Studio

**AI Model Studio** is a **cross-platform FireMonkey (FMX)** application (Windows, Linux, macOS) that provides a seamless interface to run AI models locally—via **Docker** images from [Replicate.com](https://replicate.com)—or remotely using Replicate’s cloud API. Whether you’re generating text, images, video, or audio, AI Model Studio gives you a single, straightforward app to experiment with a wide variety of models.

---

## Cross-Platform FireMonkey

- **Written in Delphi FMX** for a native look-and-feel on Windows, Linux, and macOS.  
- Unified code base that compiles to each platform with minimal changes.  
- Leverages [Embarcadero’s FireMonkey framework](https://www.embarcadero.com/products/delphi) for rich GUI controls, media handling, and cross-platform support.

---

## Architecture Overview

### 1. Model Orchestration

1. **Model Selection**  
   - AI Model Studio categorizes AI models (text, image, video, audio, etc.) published on Replicate.com.  
   - Users can pick a specific model or category from the UI.

2. **Toggle: Local vs. Remote**  
   - **Local**:  
     - The app pulls a Docker image (if not already present) corresponding to the selected AI model from Replicate.  
     - It then runs the container, which exposes a REST API on the local machine.  
     - AI Model Studio sends inference requests to `http://localhost:<port>` (or similar) where the container listens.  
   - **Remote**:  
     - The app uses Replicate’s standard API endpoints, requiring a valid API key.  
     - This allows quick testing or usage without needing Docker installed locally (beyond the optional local usage).

### 2. Docker Integration

- **Docker Container Pull & Run**  
  - On Windows, **Docker for Windows** needs to be installed and running in the background.  
  - On Linux and macOS, standard Docker Engine (via CLI) suffices.  
  - AI Model Studio programmatically checks for the needed Docker image, pulls it if missing, and starts it.  
- **Container Lifecycle Management**  
  - The application can stop and remove containers when switching models or when the user explicitly ends the session.  
  - Logging and status notifications keep the user informed of Docker commands, pull progress, and runtime events.

### 3. REST Communication

1. **Local Inference (Docker)**  
   - Once the container is active, it provides an API that mirrors Replicate’s inference endpoints.  
   - Delphi’s built-in REST client libraries handle the HTTP POST requests, sending the prompt/parameters and retrieving outputs.

2. **Remote Inference (Replicate.com)**  
   - For remote usage, the application sets the base endpoint to Replicate’s servers and includes the user’s API key.  
   - The same request/response structure is used, but no local Docker container is involved.

### 4. Core Application Components

- **Docker Command Execution**:  
  - Often done via simple command-line calls (e.g., `docker pull`, `docker run`), which the app executes in the background.  
  - On Windows, these are typically ShellExecute or command prompt calls wrapped in Delphi code.  
  - On macOS and Linux, the commands are similar, but the path or environment might differ slightly.

- **REST Client & Response Handling**:  
  - A Delphi REST client component (or direct HTTP calls) communicates with either localhost or Replicate’s URL.  
  - Handles JSON payloads for prompts, as well as media files if the model requires images/video.

### 5. Output Visualization

- **Text Generation**  
  - Results appear in a memo or large edit control inside the FMX form.  
- **Image / Video Frames**  
  - Images are displayed in `TImage` components, with the app downloading and converting them to a compatible FMX bitmap.  
- **Audio**  
  - If the model returns audio data, it is stored locally, and the UI can provide playback options or a file link.

### 6. Extensibility

- **New Models**  
  - By defining the Docker image name, model parameters, and input prompts, additional Replicate-based models can be integrated with minimal code changes.  
- **Additional Features**  
  - Since the application’s structure is modular, developers can add more advanced configurations, logging, or specialized controls for custom models.

---

## License

This project is released under the [MIT License](LICENSE) (or whichever license is defined in this repository). Please check the `LICENSE` file for details.

---

## Contributing

We welcome contributions of all kinds—whether it’s adding support for new models, improving Docker orchestration, or enhancing the user interface.

1. **Fork** the repository  
2. Create a feature branch (`git checkout -b feature/my-new-feature`)  
3. Commit your changes (`git commit -am 'Add a new feature'`)  
4. Push to the branch (`git push origin feature/my-new-feature`)  
5. Create a new Pull Request

For major changes, please open an issue first to discuss what you would like to change.

---

### Acknowledgments

- **Delphi & FireMonkey**: For a unified cross-platform GUI framework.  
- **Replicate**: For hosting and distributing AI models via Docker images and providing a robust cloud inference API.  

Enjoy exploring local and remote AI models with **AI Model Studio**!
