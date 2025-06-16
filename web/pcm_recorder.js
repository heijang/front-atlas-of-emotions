let audioContext;
let processor;
let input;
let globalStream;

function startPCMStream() {
    console.log('startPCMStream called');
    navigator.mediaDevices.getUserMedia({ audio: true }).then(function (stream) {
        console.log('getUserMedia success');
        audioContext = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 16000 });
        input = audioContext.createMediaStreamSource(stream);
        processor = audioContext.createScriptProcessor(4096, 1, 1);
        console.log('AudioContext, MediaStreamSource, ScriptProcessorNode created');
        input.connect(processor);
        processor.connect(audioContext.destination);
        console.log('Nodes connected');
        processor.onaudioprocess = function (e) {
            let f32 = e.inputBuffer.getChannelData(0);
            let pcm = new Int16Array(f32.length);
            for (let i = 0; i < f32.length; i++) {
                let s = Math.max(-1, Math.min(1, f32[i]));
                pcm[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
            }
            // Flutter로 전달 (바이너리)
            if (window.onPCMChunk) window.onPCMChunk(new Uint8Array(pcm.buffer));
        };
        globalStream = stream;
    }).catch(function (err) {
        console.error('getUserMedia error', err);
    });
}

function stopPCMStream() {
    if (processor) processor.disconnect();
    if (input) input.disconnect();
    if (audioContext && audioContext.state !== "closed") audioContext.close();
    if (globalStream) {
        globalStream.getTracks().forEach(track => track.stop());
        globalStream = null;
    }
}

// mp3 파일 선택만 (사용자가 직접 선택)
window.pickMp3File = function () {
    const input = document.getElementById('mp3FileInput');
    if (!input) return;
    input.value = '';
    input.onchange = function (e) {
        const file = e.target.files[0];
        if (!file) return;
        window._selectedMp3File = file;
        if (window.onMp3FilePicked) window.onMp3FilePicked(file);
    };
    input.click();
};

// 기본 경로 파일 자동 선택 (웹에서는 로컬 파일 경로 직접 접근 불가, 서버에서 호스팅 필요)
window.setDefaultMp3File = async function () {
    // 프론트 resources 폴더에서 파일을 fetch
    const url = 'resources/sample1.mp3';
    try {
        const res = await fetch(url);
        const blob = await res.blob();
        const file = new File([blob], 'sample1.mp3', { type: 'audio/mp3' });
        window._selectedMp3File = file;
        if (window.onMp3FilePicked) window.onMp3FilePicked(file);
    } catch (e) {
        alert('기본 mp3 파일을 불러올 수 없습니다. resources 폴더에 sample1.mp3가 있어야 합니다.');
    }
};

let _mp3StreamingCtx = null;
let _mp3StreamingOffset = 0;
let _mp3StreamingRaw = null;
let _mp3StreamingTimer = null;

// mp3 스트리밍 시작 (chunk 방식)
window.startMp3Streaming = async function () {
    const file = window._selectedMp3File;
    if (!file) {
        alert('먼저 mp3 파일을 선택하세요.');
        return;
    }
    const arrayBuffer = await file.arrayBuffer();
    _mp3StreamingCtx = new (window.AudioContext || window.webkitAudioContext)({ sampleRate: 16000 });
    _mp3StreamingCtx.decodeAudioData(arrayBuffer, function (audioBuffer) {
        _mp3StreamingRaw = audioBuffer.getChannelData(0);
        _mp3StreamingOffset = 0;
        const chunkSize = 4096;
        const sampleRate = 16000;
        function sendChunk() {
            if (_mp3StreamingOffset >= _mp3StreamingRaw.length) {
                _mp3StreamingCtx.close();
                _mp3StreamingCtx = null;
                _mp3StreamingRaw = null;
                _mp3StreamingTimer = null;
                return;
            }
            const end = Math.min(_mp3StreamingOffset + chunkSize, _mp3StreamingRaw.length);
            const f32 = _mp3StreamingRaw.subarray(_mp3StreamingOffset, end);
            const pcm = new Int16Array(f32.length);
            for (let i = 0; i < f32.length; i++) {
                let s = Math.max(-1, Math.min(1, f32[i]));
                pcm[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
            }
            if (window.onPCMChunk) window.onPCMChunk(new Uint8Array(pcm.buffer));
            _mp3StreamingOffset = end;
            _mp3StreamingTimer = setTimeout(sendChunk, chunkSize / sampleRate * 1000);
        }
        sendChunk();
    });
};

// mp3 스트리밍 정지
window.stopMp3Streaming = function () {
    if (_mp3StreamingTimer) clearTimeout(_mp3StreamingTimer);
    if (_mp3StreamingCtx) _mp3StreamingCtx.close();
    _mp3StreamingCtx = null;
    _mp3StreamingRaw = null;
    _mp3StreamingTimer = null;
    _mp3StreamingOffset = 0;
}; 