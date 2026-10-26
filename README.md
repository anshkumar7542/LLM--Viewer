# LLM-Viewer

<p align="center">
  <img src="figs/eye.png" alt="LLM-Viewer Logo" width="60"/>
</p>

**LLM-Viewer** is an interactive visualization and performance analysis tool for Large Language Models (LLMs) and Diffusion Models (DiT). Built upon the Roofline analytical model, it evaluates network-wide inference performance—such as computation operations (FLOPs/OPs), memory bandwidth bottlenecks, KV-cache growth, peak memory footprints, and latency—across varied hardware accelerator architectures (NVIDIA GPUs and Intel CPUs).

LLM-Viewer operates without requiring large multi-GPU clusters to physically execute weights, relying on analytical architecture definitions and hardware operational specifications.

---

## Key Features

- **Interactive Model Architecture Graph**: Visualizes layer topologies (attention, projections, activations, normalization) with interactive node inspection.
- **Roofline Analysis**: Maps computational intensity against theoretical peak FLOPs and memory bandwidth bounds to identify memory-bound vs. compute-bound layers.
- **Hardware Platform Profiling**: Supports profiling across diverse hardware targets including NVIDIA H100 (SXM/PCIe), A100 (40GB/80GB), A800, A6000, A40, V100, L40, and Intel Core i9-13900K.
- **Inference Optimization Simulation**:
  - Quantization bitwidths: FP16, INT8, INT4 for weights, activations, and KV cache.
  - FlashAttention vs standard attention simulation.
  - Tensor Parallelism (`--tp-size`).
  - Prefill vs. Decode stage profiling.
- **Multi-Interface Access**: Both an interactive Vue 3 web interface and rich Command Line Interface (CLI) tools.
- **Automated CSV Reporting**: Exports comprehensive metrics into CSV spreadsheets for offline analysis.

---

## Technology Stack

- **Backend**:
  - Python 3.10+
  - Flask (REST API)
  - Flask-CORS (Cross-Origin Resource Sharing)
  - Hugging Face Transformers & `AutoConfig` (Model architectural specifications)
  - NumPy & EasyDict (Numerical evaluation and state modeling)
- **Frontend**:
  - Vue 3 (Composition API)
  - Vite (Build tool and development server)
  - AntV G6 (Graph visualization engine)
  - Chart.js & `chartjs-plugin-annotation` (Performance charting)
  - Axios (HTTP client)
- **Database**:
  - None required. Analytical evaluation is computed in-memory based on model configs and hardware constants.

---

## Project Structure

```text
LLM-Viewer/
├── configs/                  # Model architecture graph definitions
│   ├── Llama.py              # LLaMA / LLaMA-2 layer graphs and mappings
│   ├── opt.py                # Meta OPT layer graphs
│   ├── chatglm3.py           # ChatGLM3 architecture graph
│   ├── gpt-j-6B.py           # EleutherAI GPT-J graph
│   └── DiT.py                # Diffusion Transformer graph
├── hardwares/                # Hardware accelerator specifications
│   └── hardware_params.py    # Bandwidth, FP16/INT8 TFLOPs, buffer sizes
├── model_params/             # Local offline model parameter profiles
│   └── DiT.py                # DiT model dimensions and hyperparams
├── frontend/                 # Vue 3 + Vite frontend application
│   ├── public/               # Static assets
│   ├── src/                  # Vue components, stores, styles
│   │   ├── components/       # Header, Graph, LeftPanel, RooflineChart
│   │   ├── App.vue           # Main application shell
│   │   └── main.js           # Vue entrypoint
│   ├── package.json          # Node dependencies and scripts
│   └── vite.config.js        # Vite configuration
├── backend_app.py            # Flask API server
├── backend_settings.py       # Available models and hardware registries
├── model_analyzer.py         # Core Roofline performance analyzer engine
├── roofline_model.py         # Roofline model calculation formulas
├── get_model_graph.py        # Graph node and edge generation pipeline
├── analyze_cli.py            # CLI tool for layer-wise Roofline analysis
├── analyze_gen_cli.py        # CLI tool for end-to-end generation benchmarks
├── utils.py                  # Number formatting and display utilities
├── requirements.txt          # Python dependencies
├── .env.example              # Environment variables template
├── run_all.bat               # Windows single-click launcher (Backend + Frontend)
├── run_backend.bat           # Windows single-click launcher (Backend only)
├── run_frontend.bat          # Windows single-click launcher (Frontend only)
└── README.md                 # Project documentation
```

---

## Installation & Setup

### Prerequisites
- **Python**: Version 3.10 to 3.14
- **Node.js**: Version 18+ and `npm`
- **Git**

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd LLM-Viewer-main
```

### 2. Backend Setup
Create and activate a Python virtual environment:
```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# Linux / macOS
python3 -m venv venv
source venv/bin/activate
```

Install backend dependencies:
```bash
pip install -r requirements.txt
```

### 3. Frontend Setup
Navigate into the `frontend` directory and install npm packages:
```bash
cd frontend
npm install
cd ..
```

---

## Configuration & Environment Variables

Copy `.env.example` to `.env` (optional, for custom network ports or Hugging Face tokens):
```bash
cp .env.example .env
```

| Variable | Default | Description |
| :--- | :--- | :--- |
| `PORT` | `5000` | Flask backend port |
| `HOST` | `127.0.0.1` | Flask backend listening host |
| `HF_TOKEN` | *(optional)* | Hugging Face access token for private/gated repositories |

---

## Running the Application

### Option A: Single-Click Launcher (Windows)
Double-click `run_all.bat`. It starts both backend and frontend servers in separate terminal windows and opens `http://localhost:5173/` in your browser.

### Option B: Manual Execution

1. **Start the Backend API**:
   ```bash
   # In root directory with venv activated
   python backend_app.py --local --port 5000
   ```
   *The backend will be available at `http://127.0.0.1:5000/`.*

2. **Start the Frontend UI**:
   ```bash
   cd frontend
   npm run dev
   ```
   *The frontend will be available at `http://localhost:5173/`.*

---

## CLI Usage

You can also run headless analyses directly from your terminal:

```bash
# Analyze OPT-125M on NVIDIA A6000:
python analyze_cli.py facebook/opt-125m nvidia_A6000

# Analyze LLaMA-2 7B with custom sequence length and batch size:
python analyze_cli.py meta-llama/Llama-2-7b-hf nvidia_A6000 --batchsize 1 --seqlen 2048

# Analyze Tensor Parallelism (e.g. 2 GPUs):
python analyze_cli.py meta-llama/Llama-2-13b-hf nvidia_A6000 --tp-size 2

# Analyze DiT (Diffusion Transformer) with local source configs:
python analyze_cli.py DiT-XL/2 nvidia_A6000 --batchsize 1 --seqlen 256 --source DiT

# Generation task benchmark (Latency, TTFT, and Throughput):
python analyze_gen_cli.py facebook/opt-125m nvidia_A6000 --batchsize 1 --seqlen 1024 --promptlen 128
```

Analysis results are automatically saved to `output/<model_id>_decode.csv` and `output/<model_id>_prefill.csv`.

---

## API Endpoints

The Flask backend exposes the following REST endpoints:

| Method | Endpoint | Description | Sample Request / Response |
| :--- | :--- | :--- | :--- |
| `GET` | `/` | Health check | Returns `"backend server ready."` |
| `GET` | `/get_avaliable` | Lists supported models and hardware | Returns `{"avaliable_hardwares": [...], "avaliable_model_ids": [...]}` |
| `POST` | `/get_graph` | Computes architecture graph & roofline metrics | Body: `{"model_id": "...", "hardware": "...", "inference_config": {...}}` |

---

## Building for Production

To build the static frontend bundle for deployment:
```bash
cd frontend
npm run build
```
The compiled assets will be created in `frontend/dist/`.

For production backend hosting, run Flask behind a WSGI server like `gunicorn` (Linux) or `waitress` (Windows):
```bash
pip install waitress
waitress-serve --port=5000 backend_app:app
```

---

## Citation

If you use LLM-Viewer in your research, please cite the survey paper:

```bibtex
@misc{yuan2024llm,
      title={LLM Inference Unveiled: Survey and Roofline Model Insights}, 
      author={Zhihang Yuan and Yuzhang Shang and Yang Zhou and Zhen Dong and Chenhao Xue and Bingzhe Wu and Zhikai Li and Qingyi Gu and Yong Jae Lee and Yan Yan and Beidi Chen and Guangyu Sun and Kurt Keutzer},
      year={2024},
      eprint={2402.16363},
      archivePrefix={arXiv},
      primaryClass={cs.CL}
}
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.