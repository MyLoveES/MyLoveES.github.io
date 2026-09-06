---
title: " AI Services On Ascend"
date: 2026-05-13
categories:
  - 技术
  - 教程
tags:
  - ai
  - ascend
toc: true
image: qwen3-asr-ascend.png
---
## 一、QWEN3-ASR

### 1. 基本变量

```
export QWEN3_ASR_WORK=/home/ruili/qwen3-asr
export QWEN3_ASR_NPU_ID=1
export QWEN3_ASR_PORT=18000
export QWEN3_ASR_BASE_IMAGE=quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler
export QWEN3_ASR_NPU_SMI=$(command -v npu-smi)
```

```
mkdir -p ${QWEN3_ASR_WORK}/{models,cache,logs,audio,docker}
```

### 2. 检查宿主机

```
cat /etc/os-release
uname -a
npu-smi info

docker --version
systemctl status docker
```

如果 Docker 没启动：

```
systemctl enable --now docker
```

如果没安装 Docker，可先试：

```
yum install -y docker
systemctl enable --now docker
```

### 3. 拉取 Ascend vLLM 镜像

你的系统是 EulerOS/aarch64，910B1 属于 Atlas A2/910B 路线，所以优先用 openEuler 镜像：

```
docker pull ${QWEN3_ASR_BASE_IMAGE}
```

如果 quay.io 访问慢或失败，可以用镜像代理：

```
docker pull m.daocloud.io/quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler
docker tag m.daocloud.io/quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler ${QWEN3_ASR_BASE_IMAGE}
```

### 4. 构建 Qwen3-ASR 运行镜像

```
cat > ${QWEN3_ASR_WORK}/docker/Dockerfile <<'EOF'
ARG QWEN3_ASR_BASE_IMAGE
FROM ${QWEN3_ASR_BASE_IMAGE}

RUN python3 -m pip install --no-cache-dir -U \
    -i https://mirrors.huaweicloud.com/repository/pypi/simple \
    "modelscope>=1.35.1" openai httpx av soundfile resampy librosa websockets
EOF
```

```
docker build \
  --build-arg QWEN3_ASR_BASE_IMAGE=${QWEN3_ASR_BASE_IMAGE} \
  -t qwen3-asr-ascend:v0.1 \
  ${QWEN3_ASR_WORK}/docker
```

### 5. 下载模型

推荐先部署 Qwen3-ASR-1.7B：

```
docker run --rm --net=host \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=0 \
  -v ${QWEN3_ASR_WORK}/models:/models \
  -v ${QWEN3_ASR_WORK}/cache:/root/.cache \
  qwen3-asr-ascend:v0.1 \
  bash -lc 'modelscope download --model Qwen/Qwen3-ASR-1.7B --local_dir /models/Qwen3-ASR-1.7B'
```

如果你想先快速验证，也可以下载小模型：

```
docker run --rm --net=host \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=0 \
  -v ${QWEN3_ASR_WORK}/models:/models \
  -v ${QWEN3_ASR_WORK}/cache:/root/.cache \
  qwen3-asr-ascend:v0.1 \
  bash -lc 'modelscope download --model Qwen/Qwen3-ASR-0.6B --local_dir /models/Qwen3-ASR-0.6B'
```

后面启动命令里把 /models/Qwen3-ASR-1.7B 改成 /models/Qwen3-ASR-0.6B 即可。

### 6. 启动服务

```
docker rm -f qwen3-asr 2>/dev/null || true
```

```
docker run -d \
  --name qwen3-asr \
  --restart unless-stopped \
  --net=host \
  --ipc=host \
  --shm-size=2g \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  -e VLLM_USE_MODELSCOPE=True \
  -e ASCEND_SLOG_PRINT_TO_STDOUT=1 \
  --device=/dev/davinci${QWEN3_ASR_NPU_ID} \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/dcmi:/usr/local/dcmi:ro \
  -v ${QWEN3_ASR_NPU_SMI}:/usr/local/bin/npu-smi:ro \
  -v /usr/local/Ascend/driver/lib64/:/usr/local/Ascend/driver/lib64/:ro \
  -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  -v ${QWEN3_ASR_WORK}/models:/models \
  -v ${QWEN3_ASR_WORK}/cache:/root/.cache \
  -v ${QWEN3_ASR_WORK}/logs:/logs \
  -v ${QWEN3_ASR_WORK}/audio:/audio \
  qwen3-asr-ascend:v0.1 \
  bash -lc "exec vllm serve /models/Qwen3-ASR-1.7B \
    --served-model-name qwen3-asr \
    --host 0.0.0.0 \
    --port ${QWEN3_ASR_PORT} \
    --dtype bfloat16 \
    --gpu-memory-utilization 0.80 \
    --trust-remote-code"
```

查看启动日志：

```
docker logs -f qwen3-asr
```

### 7. 验证服务

```
curl -s http://127.0.0.1:${QWEN3_ASR_PORT}/v1/models | python3 -m json.tool
```

测试远程音频 URL：

```
curl -s http://127.0.0.1:${QWEN3_ASR_PORT}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3-asr",
    "messages": [{
      "role": "user",
      "content": [{
        "type": "audio_url",
        "audio_url": {
          "url": "https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen3-ASR-Repo/asr_en.wav"
        }
      }]
    }],
    "temperature": 0
  }' | python3 -m json.tool
```

测试本地音频文件：

```
curl -L -o ${QWEN3_ASR_WORK}/audio/asr_en.wav \
  https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen3-ASR-Repo/asr_en.wav

curl -s http://127.0.0.1:${QWEN3_ASR_PORT}/v1/audio/transcriptions \
  -F model=qwen3-asr \
  -F file=@${QWEN3_ASR_WORK}/audio/asr_en.wav | python3 -m json.tool
```

### 8. SSE 和 WebSocket

这里把 ASR 的流式能力分成两类：

1. SSE：客户端一次性上传完整音频，服务端边生成边返回文本。
2. WebSocket：客户端持续发送麦克风音频块，服务端持续返回识别结果。

上面跑通的是 `/v1/audio/transcriptions`，属于文件转写接口。如果要接麦克风实时识别，需要使用 vLLM 的 WebSocket realtime 接口：

```
ws://<server>:<port>/v1/realtime
```

#### 8.1 SSE

SSE 适合“完整文件上传后流式返回文本”的场景。它不需要客户端持续推送音频块，也不需要额外启动 realtime 服务。

这个方式不需要重启服务：

```
curl -N -sS http://127.0.0.1:${QWEN3_ASR_PORT}/v1/audio/transcriptions \
  -F model=qwen3-asr \
  -F file=@${QWEN3_ASR_WORK}/audio/asr_en.wav \
  -F stream=true
```

其中 `-N` 是让 curl 不缓存输出，`stream=true` 是让 vLLM 尽量流式返回。注意：这仍然是完整文件上传，不是麦克风实时流。

#### 8.2 WebSocket

WebSocket 适合真正的麦克风实时识别：客户端持续发送音频块，服务端持续返回识别结果。

##### 8.2.1 启动 Realtime 服务

建议单独起一个 realtime 服务，不影响当前 batch 服务。下面示例使用空闲的 NPU 2 和端口 18001：

```
export WORK=/home/xx/qwen3-asr
export WEBSOCKET_NPU_ID=2
export REALTIME_PORT=18001
```

```
docker rm -f qwen3-asr-realtime 2>/dev/null || true
```

```
docker run -d \
  --name qwen3-asr-realtime \
  --restart unless-stopped \
  --net=host \
  --ipc=host \
  --shm-size=2g \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  -e ASCEND_SLOG_PRINT_TO_STDOUT=1 \
  --device=/dev/davinci${QWEN3_ASR_WEBSOCKET_NPU_ID}:/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/dcmi:/usr/local/dcmi:ro \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
  -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  -v ${QWEN3_ASR_WORK}/models:/models \
  -v ${QWEN3_ASR_WORK}/cache:/root/.cache \
  -v ${QWEN3_ASR_WORK}/audio:/audio \
  qwen3-asr-ascend:v0.1 \
  bash -lc "exec vllm serve /models/Qwen3-ASR-1.7B \
    --served-model-name qwen3-asr \
    --host 0.0.0.0 \
    --port ${QWEN3_ASR_REALTIME_PORT} \
    --dtype bfloat16 \
    --gpu-memory-utilization 0.80 \
    --trust-remote-code \
    --hf-overrides '{\"architectures\": [\"Qwen3ASRRealtimeGeneration\"]}' \
    --enforce-eager \
    --max-model-len 4096 \
    --limit-mm-per-prompt '{\"audio\": 1}' \
	--no-async-scheduling "
```

查看日志：

```
docker logs -f qwen3-asr-realtime
```

##### 8.2.2 WebSocket 协议

客户端连接：

```
ws://127.0.0.1:18001/v1/realtime
```

音频格式要求：

- PCM16
- 16kHz
- mono
- base64

客户端先发送 session 配置：

```json
{"type": "session.update", "model": "qwen3-asr"}
```

再发送一次空 commit，表示可以开始接收音频：

```json
{"type": "input_audio_buffer.commit"}
```

然后持续发送音频块：

```json
{"type": "input_audio_buffer.append", "audio": "<base64-pcm16-chunk>"}
```

结束时发送：

```json
{"type": "input_audio_buffer.commit", "final": true}
```

服务端会返回增量文本：

```json
{"type": "transcription.delta", "delta": "部分文本"}
```

最终返回完整文本：

```json
{"type": "transcription.done", "text": "完整文本"}
```

##### 8.2.3 用文件模拟流式测试

创建测试客户端：

```
cat > ${QWEN3_ASR_WORK}/realtime_file_client.py <<'PY'
import argparse
import asyncio
import base64
import json

import librosa
import numpy as np
import websockets


async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=18001)
    parser.add_argument("--model", default="qwen3-asr")
    parser.add_argument("--chunk-ms", type=int, default=200)
    args = parser.parse_args()

    audio, _ = librosa.load(args.file, sr=16000, mono=True)
    audio = np.clip(audio, -1.0, 1.0)
    pcm16 = (audio * 32767).astype(np.int16).tobytes()

    bytes_per_chunk = 16000 * 2 * args.chunk_ms // 1000
    uri = f"ws://{args.host}:{args.port}/v1/realtime"

    async with websockets.connect(uri, max_size=None) as ws:
        print(await ws.recv())

        await ws.send(json.dumps({"type": "session.update", "model": args.model}))
        await ws.send(json.dumps({"type": "input_audio_buffer.commit"}))

        async def send_audio():
            for i in range(0, len(pcm16), bytes_per_chunk):
                chunk = pcm16[i:i + bytes_per_chunk]
                await ws.send(json.dumps({
                    "type": "input_audio_buffer.append",
                    "audio": base64.b64encode(chunk).decode("utf-8"),
                }))
                await asyncio.sleep(args.chunk_ms / 1000)

            await ws.send(json.dumps({
                "type": "input_audio_buffer.commit",
                "final": True,
            }))

        async def recv_text():
            while True:
                msg = json.loads(await ws.recv())
                msg_type = msg.get("type")

                if msg_type == "transcription.delta":
                    print(msg.get("delta", ""), end="", flush=True)
                elif msg_type == "transcription.done":
                    print("\n\nFINAL:")
                    print(msg.get("text", ""))
                    break
                elif msg_type == "error":
                    print("\nERROR:")
                    print(msg)
                    break

        await asyncio.gather(send_audio(), recv_text())


asyncio.run(main())
PY
```

用 Docker 镜像跑客户端：

```
docker run --rm --net=host \
  -v ${QWEN3_ASR_WORK}/audio:/audio \
  -v ${QWEN3_ASR_WORK}/realtime_file_client.py:/client.py \
  qwen3-asr-ascend:v0.1 \
  python3 /client.py \
    --file /audio/asr_en.wav \
    --host 127.0.0.1 \
    --port ${QWEN3_ASR_REALTIME_PORT} \
    --model qwen3-asr
```

#### 8.3 接业务系统时的关键点

浏览器或客户端不能直接把 webm、mp3、wav 原样塞给 `/v1/realtime`。需要先转成：

```
16kHz 单声道 PCM16
```

推荐链路：

```
麦克风
  -> AudioWorklet / 原生录音 SDK
  -> 重采样到 16k
  -> int16 PCM
  -> base64
  -> WebSocket /v1/realtime
  -> 接收 transcription.delta / transcription.done
```

生产环境如果走 Nginx，WebSocket 要加 upgrade：

```nginx
location /v1/realtime {
    proxy_pass http://127.0.0.1:18001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 3600s;
}
```

注意：vLLM 的 Qwen3-ASR realtime 路径目前更偏实验性，内部会按片段处理音频，实时性和稳定性要实际压测。如果要做正式在线语音助手，建议先用上面的文件模拟流式跑通，再接麦克风，并重点观察重复文本、片段延迟和长连接稳定性。

### 9. 常用运维命令

```
docker logs -f qwen3-asr
docker restart qwen3-asr
docker stop qwen3-asr
docker rm -f qwen3-asr
npu-smi info
```

### 10. 注意事项

- 如果 batch 服务端口冲突，改 `export PORT=18002` 或其他空闲端口后重新执行启动命令；realtime 服务同理修改 `REALTIME_PORT`。
- 如果报 CANN/driver/libascendcl/torch_npu 相关错误，优先怀疑宿主机驱动和容器内 CANN/torch-npu 版本不匹配。
- 如果要公网访问，按实际服务开放云安全组或防火墙里的 `PORT` / `REALTIME_PORT` 对应端口。

### 11. 参考

- https://github.com/QwenLM/Qwen3-ASR
- https://docs.vllm.ai/en/stable/serving/openai_compatible_server/
- https://docs.vllm.ai/en/latest/examples/speech_to_text/realtime/
- https://docs.vllm.ai/projects/recipes/en/latest/Qwen/Qwen3-ASR.html
- https://docs.vllm.ai/projects/ascend/en/latest/quick_start.html
- https://docs.vllm.ai/projects/ascend/en/latest/installation.html

## 二、IndexTTS2

IndexTTS2 官方仓库默认按 CUDA / CPU 环境组织依赖，`pyproject.toml` 里 Linux 的 `torch` 源会指向 CUDA 12.8。因此在 Ascend 910B 上不要直接执行官方文档里的 `uv sync --all-extras`，否则很容易装到 CUDA 版 PyTorch，最后只能 CPU 跑或者直接报错。

下面的方式使用 Ascend PyTorch 容器运行。你的机器上 NPU 0 已经被 `mindie_llm_back` 占用，所以示例默认使用 NPU 1。如果 NPU 1 也被占用，就把 `NPU_ID` 改成 2-7 中的空闲卡。

### 1. 基本变量

```
export WORK=/home/xx/indextts
export NPU_ID=1
export WEBUI_PORT=17860
export API_PORT=17861
export BASE_IMAGE=quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler
export NPU_SMI=$(command -v npu-smi)
```

```
mkdir -p ${INDEX_TTS_WORK}/{code,models,cache,outputs,prompts,docker,logs}
```

### 2. 检查宿主机

```
cat /etc/os-release
uname -a
npu-smi info
docker --version
systemctl status docker
```

如果 Docker 没启动：

```
systemctl enable --now docker
```

如果没有安装 Docker：

```
yum install -y docker
systemctl enable --now docker
```

### 3. 拉取基础镜像

这里复用前面 Qwen3-ASR 使用的 Ascend vLLM 镜像，主要是因为它已经包含 openEuler、CANN、PyTorch / torch-npu 这一套基础环境：

```
docker pull ${INDEX_TTS_BASE_IMAGE}
```

如果 quay.io 访问慢或失败：

```
docker pull m.daocloud.io/quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler
docker tag m.daocloud.io/quay.io/ascend/vllm-ascend:v0.19.1rc1-openeuler ${INDEX_TTS_BASE_IMAGE}
```

### 4. 构建 IndexTTS2 运行镜像

先写 Dockerfile。这里有两个关键点：

1. 不执行 `uv sync --all-extras`，避免拉 CUDA 版 PyTorch。
2. 只安装 IndexTTS2 的 Python 依赖，保留基础镜像里的 Ascend PyTorch / torch-npu 运行栈。

```
cat > ${INDEX_TTS_WORK}/docker/Dockerfile <<'EOF'
ARG INDEX_TTS_BASE_IMAGE
FROM ${INDEX_TTS_BASE_IMAGE}

ENV PIP_INDEX_URL=https://mirrors.huaweicloud.com/repository/pypi/simple \
    PIP_TRUSTED_HOST=mirrors.huaweicloud.com \
    HF_HOME=/root/.cache/huggingface \
    HF_HUB_CACHE=/root/.cache/huggingface/hub \
    MODELSCOPE_CACHE=/root/.cache/modelscope \
    TORCH_DEVICE_BACKEND_AUTOLOAD=1

RUN yum install -y git git-lfs libsndfile && yum clean all

RUN python3 -m pip install --no-cache-dir -U pip setuptools wheel

RUN python3 -m pip install --no-cache-dir \
    accelerate==1.8.1 \
    cn2an==0.5.22 \
    cython==3.0.7 \
    descript-audiotools==0.7.2 \
    einops==0.8.1 \
    ffmpeg-python==0.2.0 \
    g2p-en==2.1.0 \
    jieba==0.42.1 \
    json5==0.10.0 \
    keras==2.9.0 \
    librosa==0.10.2.post1 \
    matplotlib==3.8.2 \
    "modelscope>=1.35.1" \
    munch==4.0.0 \
    numba==0.58.1 \
    numpy==1.26.2 \
    omegaconf==2.3.0 \
    opencv-python-headless==4.9.0.80 \
    pandas==2.3.2 \
    safetensors==0.5.2 \
    sentencepiece==0.2.1 \
    tensorboard==2.9.1 \
    textstat==0.7.10 \
    tokenizers==0.21.0 \
    torchaudio==2.9.0 \
    tqdm==4.67.1 \
    transformers==4.52.1 \
    wetext==0.1.2 \
    gradio==5.45.0 \
    fastapi uvicorn python-multipart soundfile
EOF
```

构建镜像：

```
docker build \
  --build-arg INDEX_TTS_BASE_IMAGE=${INDEX_TTS_BASE_IMAGE} \
  -t indextts-ascend:v0.1 \
  ${INDEX_TTS_WORK}/docker
```

验证容器内 PyTorch 能看到 NPU：

```
docker run --rm --net=host --ipc=host \
  -e ASCEND_VISIBLE_DEVICES=0 \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  --device=/dev/davinci${INDEX_TTS_NPU_ID}:/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  indextts-ascend:v0.1 \
  bash -lc 'source /usr/local/Ascend/ascend-toolkit/set_env.sh 2>/dev/null || true
python3 - <<PY
import torch
try:
    import torch_npu
except Exception as e:
    print("torch_npu import failed:", repr(e))
print("torch:", torch.__version__)
print("has npu:", hasattr(torch, "npu"))
print("npu available:", hasattr(torch, "npu") and torch.npu.is_available())
if hasattr(torch, "npu") and torch.npu.is_available():
    x = torch.randn(2, 2, device="npu:0")
    print(x @ x)
PY'
```

如果这里 `npu available` 不是 `True`，优先排查三件事：

- 容器是否正确挂载了 `/dev/davinci${INDEX_TTS_NPU_ID}`、`/dev/davinci_manager`、`/dev/devmm_svm`、`/dev/hisi_hdc`。
- 容器内 `torch`、`torch_npu`、CANN 和宿主机驱动是否匹配。
- 这个 NPU 是否正在被别的进程占用。

### 5. 下载代码

```
docker run --rm --net=host \
  -v ${INDEX_TTS_WORK}/code:/code \
  indextts-ascend:v0.1 \
  bash -lc 'cd /code && git clone https://github.com/index-tts/index-tts.git && cd index-tts && git lfs install && git lfs pull'
```

如果 GitHub 慢，可以先在其他机器下载好仓库和 LFS 文件，再同步到：

```
${INDEX_TTS_WORK}/code/index-tts
```

### 6. 下载模型

优先从 ModelScope 下载，国内环境会稳定一些：

```
docker run --rm --net=host \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=0 \
  -v ${INDEX_TTS_WORK}/models:/models \
  -v ${INDEX_TTS_WORK}/cache:/root/.cache \
  indextts-ascend:v0.1 \
  bash -lc 'modelscope download --model IndexTeam/IndexTTS-2 --local_dir /models/IndexTTS-2'
```

下载完成后确认关键文件存在：

```
ls -lh ${INDEX_TTS_WORK}/models/IndexTTS-2
```

至少应能看到：

```
bpe.model
config.yaml
gpt.pth
s2mel.pth
wav2vec2bert_stats.pt
```

第一次运行时，IndexTTS2 还会自动下载几个小模型和声码器，例如 `facebook/w2v-bert-2.0`、`amphion/MaskGCT`、`funasr/campplus`、BigVGAN。建议先预热 HuggingFace 缓存，避免第一次推理时边占 NPU 边等网络：

```
docker run --rm --net=host \
  -e HF_ENDPOINT=https://hf-mirror.com \
  -e HF_HOME=/root/.cache/huggingface \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=0 \
  -v ${INDEX_TTS_WORK}/cache:/root/.cache \
  indextts-ascend:v0.1 \
  bash -lc 'python3 - <<PY
from huggingface_hub import hf_hub_download

files = [
    ("facebook/w2v-bert-2.0", "preprocessor_config.json"),
    ("amphion/MaskGCT", "semantic_codec/model.safetensors"),
    ("funasr/campplus", "campplus_cn_common.bin"),
    ("nvidia/bigvgan_v2_22khz_80band_256x", "config.json"),
    ("nvidia/bigvgan_v2_22khz_80band_256x", "bigvgan_generator.pt"),
]

for repo_id, filename in files:
    print(f"download {repo_id}/{filename}")
    hf_hub_download(repo_id=repo_id, filename=filename)
PY'
```

如果这里连接 `hf-mirror.com` 超时，可以去掉 `HF_ENDPOINT` 改连 HuggingFace 官方站点，或者在外网机器预下载后把 HuggingFace 缓存目录同步到 `${INDEX_TTS_WORK}/cache/huggingface`。后面的启动命令会继续挂载 `${INDEX_TTS_WORK}/cache`，并设置 `HF_ENDPOINT=https://hf-mirror.com`。

### 7. 给 IndexTTS2 加 Ascend 适配补丁

官方代码没有专门处理 `npu:0`，WebUI 也没有暴露 `--device` 参数。这里做一个小补丁：

- 导入 `torch_npu`。
- 自动识别 `torch.npu`。
- WebUI 增加 `--device npu:0`。
- 情绪文本模型从 CPU 改为可以放到同一张 NPU。
- `torchaudio.compliance.kaldi.fbank` 保持在 CPU 上算，再把结果搬回 NPU，避免 NPU 上遇到未适配算子。
- Linux 文本归一化默认从 `WeTextProcessing` 切到 `wetext` runtime，避开 ARM 上容易出问题的 `pynini` 编译依赖。
- 清理 cache 时从只调用 `torch.cuda.empty_cache()` 改成按实际设备清理。

```
docker run --rm -i \
  -v ${INDEX_TTS_WORK}/code/index-tts:/workspace \
  -w /workspace \
  indextts-ascend:v0.1 \
  python3 - <<'PY'
from pathlib import Path


def replace_once(text, old, new, label):
    if new in text:
        return text
    if old not in text:
        raise SystemExit(f"patch failed: {label}")
    return text.replace(old, new, 1)


infer_path = Path("indextts/infer_v2.py")
infer = infer_path.read_text()

infer = replace_once(
    infer,
    "import librosa\nimport torch\nimport torchaudio\n",
    "import librosa\nimport torch\ntry:\n    import torch_npu  # noqa: F401\nexcept Exception:\n    torch_npu = None\nimport torchaudio\n",
    "import torch_npu",
)

infer = replace_once(
    infer,
    "from transformers import SeamlessM4TFeatureExtractor\nimport random\nimport torch.nn.functional as F\n",
    "from transformers import SeamlessM4TFeatureExtractor\nimport random\nimport torch.nn.functional as F\n\n\ndef empty_device_cache():\n    if hasattr(torch, \"npu\") and torch.npu.is_available():\n        torch.npu.empty_cache()\n    elif torch.cuda.is_available():\n        torch.cuda.empty_cache()\n",
    "empty_device_cache",
)

infer = replace_once(
    infer,
    '        elif hasattr(torch, "xpu") and torch.xpu.is_available():\n            self.device = "xpu"\n            self.use_fp16 = use_fp16\n            self.use_cuda_kernel = False\n',
    '        elif hasattr(torch, "npu") and torch.npu.is_available():\n            self.device = "npu:0"\n            self.use_fp16 = use_fp16\n            self.use_cuda_kernel = False\n        elif hasattr(torch, "xpu") and torch.xpu.is_available():\n            self.device = "xpu"\n            self.use_fp16 = use_fp16\n            self.use_cuda_kernel = False\n',
    "npu device select",
)

infer = replace_once(
    infer,
    "        self.qwen_emo = QwenEmotion(os.path.join(self.model_dir, self.cfg.qwen_emo_path))\n",
    "        self.qwen_emo = QwenEmotion(os.path.join(self.model_dir, self.cfg.qwen_emo_path), device=self.device)\n",
    "qwen emotion device",
)

cache_call = "                torch.cuda.empty_cache()"
if cache_call in infer:
    infer = infer.replace(cache_call, "                empty_device_cache()")
elif "                empty_device_cache()" not in infer:
    raise SystemExit("patch failed: empty cache replacement")

infer = replace_once(
    infer,
    "            feat = torchaudio.compliance.kaldi.fbank(audio_16k.to(ref_mel.device),\n                                                     num_mel_bins=80,\n                                                     dither=0,\n                                                     sample_frequency=16000)\n",
    "            feat = torchaudio.compliance.kaldi.fbank(\n                audio_16k.cpu(),\n                num_mel_bins=80,\n                dither=0,\n                sample_frequency=16000,\n            ).to(ref_mel.device)\n",
    "kaldi fbank cpu",
)

infer = replace_once(
    infer,
    'class QwenEmotion:\n    def __init__(self, model_dir):\n        self.model_dir = model_dir\n        self.tokenizer = AutoTokenizer.from_pretrained(self.model_dir)\n        self.model = AutoModelForCausalLM.from_pretrained(\n            self.model_dir,\n            torch_dtype="float16",  # "auto"\n            device_map="auto"\n        )\n        self.prompt = "文本情感分类"\n',
    'class QwenEmotion:\n    def __init__(self, model_dir, device=None):\n        self.model_dir = model_dir\n        self.tokenizer = AutoTokenizer.from_pretrained(self.model_dir)\n        dtype = torch.float16 if device and device != "cpu" else torch.float32\n        self.model = AutoModelForCausalLM.from_pretrained(\n            self.model_dir,\n            torch_dtype=dtype,\n        )\n        if device and device != "cpu":\n            self.model = self.model.to(device)\n        self.model.eval()\n        self.prompt = "文本情感分类"\n',
    "QwenEmotion init",
)

infer_path.write_text(infer)

webui_path = Path("webui.py")
webui = webui_path.read_text()
webui = replace_once(
    webui,
    'parser.add_argument("--model_dir", type=str, default="./checkpoints", help="Model checkpoints directory")\nparser.add_argument("--fp16", action="store_true", default=False, help="Use FP16 for inference if available")\n',
    'parser.add_argument("--model_dir", type=str, default="./checkpoints", help="Model checkpoints directory")\nparser.add_argument("--device", type=str, default=None, help="Device to run on, for example npu:0, cuda:0, cpu")\nparser.add_argument("--fp16", action="store_true", default=False, help="Use FP16 for inference if available")\n',
    "webui device argument",
)
webui = replace_once(
    webui,
    "                use_deepspeed=cmd_args.deepspeed,\n                use_cuda_kernel=cmd_args.cuda_kernel,\n                )\n",
    "                use_deepspeed=cmd_args.deepspeed,\n                use_cuda_kernel=cmd_args.cuda_kernel,\n                device=cmd_args.device,\n                )\n",
    "webui device pass",
)
webui_path.write_text(webui)

front_path = Path("indextts/utils/front.py")
front = front_path.read_text()
front = replace_once(
    front,
    '''        import platform
        if self.zh_normalizer is not None and self.en_normalizer is not None:
            return
        if platform.system() != "Linux":  # Mac and Windows
            from wetext import Normalizer

            self.zh_normalizer = Normalizer(remove_erhua=False, lang="zh", operator="tn")
            self.en_normalizer = Normalizer(lang="en", operator="tn")
        else:
            from tn.chinese.normalizer import Normalizer as NormalizerZh
            from tn.english.normalizer import Normalizer as NormalizerEn
            # use new cache dir for build tagger rules with disable remove_interjections and remove_erhua
            cache_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tagger_cache")
            if not os.path.exists(cache_dir):
                os.makedirs(cache_dir)
                with open(os.path.join(cache_dir, ".gitignore"), "w") as f:
                    f.write("*\\n")
            self.zh_normalizer = NormalizerZh(
                cache_dir=cache_dir, remove_interjections=False, remove_erhua=False, overwrite_cache=False
            )
            self.en_normalizer = NormalizerEn(overwrite_cache=False)
''',
    '''        if self.zh_normalizer is not None and self.en_normalizer is not None:
            return
        from wetext import Normalizer

        self.zh_normalizer = Normalizer(
            remove_interjections=False,
            remove_erhua=False,
            lang="zh",
            operator="tn",
        )
        self.en_normalizer = Normalizer(lang="en", operator="tn")
''',
    "wetext runtime",
)
front_path.write_text(front)

print("IndexTTS2 Ascend patch applied.")
PY
```

### 8. 创建命令行验证脚本

官方 `indextts` CLI 目前还是 IndexTTS1 入口，这里单独放一个 IndexTTS2 的 NPU 验证脚本：

```
cat > ${INDEX_TTS_WORK}/code/index-tts/ascend_infer.py <<'PY'
import argparse
import os

import torch

try:
    import torch_npu  # noqa: F401
except Exception:
    torch_npu = None

from indextts.infer_v2 import IndexTTS2


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_dir", default="/opt/index-tts/checkpoints")
    parser.add_argument("--voice", required=True)
    parser.add_argument("--text", required=True)
    parser.add_argument("--output_path", default="/opt/index-tts/outputs/gen.wav")
    parser.add_argument("--device", default="npu:0")
    parser.add_argument("--fp16", action="store_true")
    args = parser.parse_args()

    cfg_path = os.path.join(args.model_dir, "config.yaml")
    print("torch:", torch.__version__)
    print("device:", args.device)
    print("npu available:", hasattr(torch, "npu") and torch.npu.is_available())

    tts = IndexTTS2(
        cfg_path=cfg_path,
        model_dir=args.model_dir,
        use_fp16=args.fp16,
        use_cuda_kernel=False,
        use_deepspeed=False,
        use_torch_compile=False,
        device=args.device,
    )
    tts.infer(
        spk_audio_prompt=args.voice,
        text=args.text,
        output_path=args.output_path,
        verbose=True,
    )


if __name__ == "__main__":
    main()
PY
```

跑一次离线推理：

```
docker run --rm --net=host --ipc=host --shm-size=16g \
  -e ASCEND_VISIBLE_DEVICES=0 \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  -e HF_ENDPOINT=https://hf-mirror.com \
  -e HF_HOME=/root/.cache/huggingface \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=1 \
  --device=/dev/davinci${INDEX_TTS_NPU_ID}:/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/dcmi:/usr/local/dcmi:ro \
  -v ${INDEX_TTS_NPU_SMI}:/usr/local/bin/npu-smi:ro \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
  -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  -v ${INDEX_TTS_WORK}/code/index-tts:/opt/index-tts \
  -v ${INDEX_TTS_WORK}/models/IndexTTS-2:/opt/index-tts/checkpoints \
  -v ${INDEX_TTS_WORK}/outputs:/opt/index-tts/outputs \
  -v ${INDEX_TTS_WORK}/cache:/root/.cache \
  -w /opt/index-tts \
  indextts-ascend:v0.1 \
  bash -lc "source /usr/local/Ascend/ascend-toolkit/set_env.sh 2>/dev/null || true
python3 ascend_infer.py \
  --model_dir /opt/index-tts/checkpoints \
  --voice examples/voice_01.wav \
  --text '欢迎大家体验在昇腾 910B 上运行的 IndexTTS 二。' \
  --output_path /opt/index-tts/outputs/indextts_test.wav \
  --device npu:0 \
  --fp16"
```

输出文件在：

```
${INDEX_TTS_WORK}/outputs/indextts_test.wav
```

### 9. 启动 WebUI

```
docker rm -f indextts-webui 2>/dev/null || true
```

```
docker run -d \
  --name indextts-webui \
  --restart unless-stopped \
  --net=host \
  --ipc=host \
  --shm-size=16g \
  -e ASCEND_VISIBLE_DEVICES=0 \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  -e HF_ENDPOINT=https://hf-mirror.com \
  -e HF_HOME=/root/.cache/huggingface \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=1 \
  --device=/dev/davinci${INDEX_TTS_NPU_ID}:/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/dcmi:/usr/local/dcmi:ro \
  -v ${INDEX_TTS_NPU_SMI}:/usr/local/bin/npu-smi:ro \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
  -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  -v ${INDEX_TTS_WORK}/code/index-tts:/opt/index-tts \
  -v ${INDEX_TTS_WORK}/models/IndexTTS-2:/opt/index-tts/checkpoints \
  -v ${INDEX_TTS_WORK}/outputs:/opt/index-tts/outputs \
  -v ${INDEX_TTS_WORK}/prompts:/opt/index-tts/prompts \
  -v ${INDEX_TTS_WORK}/cache:/root/.cache \
  -w /opt/index-tts \
  indextts-ascend:v0.1 \
  bash -lc "source /usr/local/Ascend/ascend-toolkit/set_env.sh 2>/dev/null || true
exec python3 webui.py \
  --host 0.0.0.0 \
  --port ${INDEX_TTS_WEBUI_PORT} \
  --model_dir /opt/index-tts/checkpoints \
  --device npu:0 \
  --fp16"
```

查看日志：

```
docker logs -f indextts-webui
```

访问：

```
http://<server-ip>:17860
```

### 10. 启动 HTTP API

如果要接业务系统，建议单独起一个 API 服务。这里提供一个最小接口：

- `GET /health`：健康检查。
- `POST /v1/audio/speech`：上传参考音频和文本，返回 wav。

创建 API 脚本：

```
cat > ${INDEX_TTS_WORK}/code/index-tts/ascend_api.py <<'PY'
import os
import threading
import uuid
from pathlib import Path
from typing import Optional

import torch

try:
    import torch_npu  # noqa: F401
except Exception:
    torch_npu = None

from fastapi import FastAPI, File, Form, UploadFile
from fastapi.responses import FileResponse

from indextts.infer_v2 import IndexTTS2


MODEL_DIR = os.getenv("MODEL_DIR", "/opt/index-tts/checkpoints")
OUTPUT_DIR = Path(os.getenv("OUTPUT_DIR", "/opt/index-tts/outputs/tasks"))
DEVICE = os.getenv("INDEXTTS_DEVICE", "npu:0")
USE_FP16 = os.getenv("INDEXTTS_FP16", "1") == "1"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

app = FastAPI(title="IndexTTS2 Ascend API")
tts = None
lock = threading.Lock()


@app.on_event("startup")
def load_model():
    global tts
    tts = IndexTTS2(
        cfg_path=os.path.join(MODEL_DIR, "config.yaml"),
        model_dir=MODEL_DIR,
        use_fp16=USE_FP16,
        use_cuda_kernel=False,
        use_deepspeed=False,
        use_torch_compile=False,
        device=DEVICE,
    )


@app.get("/health")
def health():
    return {
        "status": "ok",
        "device": DEVICE,
        "npu_available": bool(hasattr(torch, "npu") and torch.npu.is_available()),
    }


async def save_upload(upload: UploadFile, path: Path):
    data = await upload.read()
    path.write_bytes(data)


@app.post("/v1/audio/speech")
async def speech(
    text: str = Form(...),
    voice: UploadFile = File(...),
    emo_audio: Optional[UploadFile] = File(default=None),
    emo_alpha: float = Form(default=1.0),
):
    task_id = uuid.uuid4().hex
    task_dir = OUTPUT_DIR / task_id
    task_dir.mkdir(parents=True, exist_ok=True)

    voice_path = task_dir / "voice.wav"
    out_path = task_dir / "speech.wav"
    await save_upload(voice, voice_path)

    emo_path = None
    if emo_audio is not None:
        emo_path = task_dir / "emotion.wav"
        await save_upload(emo_audio, emo_path)

    with lock:
        tts.infer(
            spk_audio_prompt=str(voice_path),
            text=text,
            output_path=str(out_path),
            emo_audio_prompt=str(emo_path) if emo_path else None,
            emo_alpha=emo_alpha,
            verbose=False,
        )

    return FileResponse(str(out_path), media_type="audio/wav", filename="speech.wav")
PY
```

启动 API：

```
docker rm -f indextts-api 2>/dev/null || true
```

```
docker run -d \
  --name indextts-api \
  --restart unless-stopped \
  --net=host \
  --ipc=host \
  --shm-size=16g \
  -e ASCEND_VISIBLE_DEVICES=0 \
  -e ASCEND_RT_VISIBLE_DEVICES=0 \
  -e ASCEND_DEVICE_ID=0 \
  -e HF_ENDPOINT=https://hf-mirror.com \
  -e HF_HOME=/root/.cache/huggingface \
  -e TORCH_DEVICE_BACKEND_AUTOLOAD=1 \
  -e MODEL_DIR=/opt/index-tts/checkpoints \
  -e OUTPUT_DIR=/opt/index-tts/outputs/tasks \
  -e INDEXTTS_DEVICE=npu:0 \
  -e INDEXTTS_FP16=1 \
  --device=/dev/davinci${INDEX_TTS_NPU_ID}:/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/dcmi:/usr/local/dcmi:ro \
  -v ${INDEX_TTS_NPU_SMI}:/usr/local/bin/npu-smi:ro \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
  -v /usr/local/Ascend/driver/version.info:/usr/local/Ascend/driver/version.info:ro \
  -v /etc/ascend_install.info:/etc/ascend_install.info:ro \
  -v ${INDEX_TTS_WORK}/code/index-tts:/opt/index-tts \
  -v ${INDEX_TTS_WORK}/models/IndexTTS-2:/opt/index-tts/checkpoints \
  -v ${INDEX_TTS_WORK}/outputs:/opt/index-tts/outputs \
  -v ${INDEX_TTS_WORK}/cache:/root/.cache \
  -w /opt/index-tts \
  indextts-ascend:v0.1 \
  bash -lc "source /usr/local/Ascend/ascend-toolkit/set_env.sh 2>/dev/null || true
exec uvicorn ascend_api:app --host 0.0.0.0 --port ${INDEX_TTS_API_PORT} --workers 1"
```

检查 API：

```
curl -s http://127.0.0.1:${INDEX_TTS_API_PORT}/health | python3 -m json.tool
```

生成测试语音：

```
curl -s -X POST http://127.0.0.1:${INDEX_TTS_API_PORT}/v1/audio/speech \
  -F "text=欢迎大家体验 IndexTTS 二，这是来自昇腾服务器的语音合成结果。" \
  -F "voice=@${INDEX_TTS_WORK}/code/index-tts/examples/voice_01.wav" \
  --output ${INDEX_TTS_WORK}/outputs/api_test.wav
```

如果要使用情绪参考音频：

```
curl -s -X POST http://127.0.0.1:${INDEX_TTS_API_PORT}/v1/audio/speech \
  -F "text=这是一段带有情绪参考的语音合成。" \
  -F "voice=@${INDEX_TTS_WORK}/code/index-tts/examples/voice_07.wav" \
  -F "emo_audio=@${INDEX_TTS_WORK}/code/index-tts/examples/emo_sad.wav" \
  -F "emo_alpha=0.8" \
  --output ${INDEX_TTS_WORK}/outputs/api_emo_test.wav
```

### 11. 常用运维命令

```
docker logs -f indextts-webui
docker restart indextts-webui
docker stop indextts-webui
docker rm -f indextts-webui

docker logs -f indextts-api
docker restart indextts-api
docker stop indextts-api
docker rm -f indextts-api

npu-smi info
```

### 12. 注意事项

- WebUI 和 API 如果同时启动在同一张 NPU 上，会各自加载一份模型，HBM 会重复占用。生产环境建议只保留 API；需要 WebUI 调试时再临时启动。
- 如果想同时跑 WebUI 和 API，建议使用两张不同的空闲卡，比如 WebUI 用 `NPU_ID=1`，API 用 `NPU_ID=2`。
- 如果构建镜像时 `torchaudio` 触发 PyTorch 版本冲突，不要让 pip 自动降级或升级基础镜像里的 `torch`。先进入基础镜像确认 `torch` / `torch-npu` 版本，再让 `torchaudio` 使用相同 minor 版本；例如 `torch==2.9.0`、`torch-npu==2.9.0` 对应 `torchaudio==2.9.0`。
- 如果报 CANN、`libascendcl.so`、`torch_npu` 相关错误，优先怀疑容器内 CANN / torch-npu 与宿主机驱动不匹配。
- 如果文本归一化报 `pynini`、`tn.chinese`、`WeTextProcessing` 相关错误，说明补丁没有生效或依赖装回了官方 Linux 路径；重新执行第 7 步补丁，并确认镜像里安装的是 `wetext`。
- 验证阶段建议参考音频使用 wav。若业务侧需要上传 mp3、m4a 等格式，再在镜像里额外安装 ffmpeg。
- 如果 `HF_ENDPOINT=https://hf-mirror.com` 仍然下载失败，可以提前在外网机器把 HuggingFace 缓存同步到 `${INDEX_TTS_WORK}/cache/huggingface`。
- 如果生成速度慢，先确认日志里打印的是 `device: npu:0`，并用 `npu-smi info` 看 AICore / HBM 是否有变化。
- 如果打开 `--fp16` 后音频异常或遇到算子错误，先去掉 `--fp16` 验证功能正确性，再考虑性能优化。
- 这个 API 示例用 `threading.Lock()` 串行化请求。IndexTTS2 不是简单的短文本 embedding 服务，单进程多并发容易互相抢显存；生产环境更建议“一张 NPU 一个进程”，再由网关做队列或负载均衡。

### 13. 参考

- https://github.com/index-tts/index-tts
- https://modelscope.cn/models/IndexTeam/IndexTTS-2
- https://huggingface.co/IndexTeam/IndexTTS-2
- https://pypi.org/project/torch-npu/
- https://github.com/Ascend/pytorch
- https://pypi.org/project/wetext/
