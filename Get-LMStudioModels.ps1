Set-StrictMode -Version 5.0
$ErrorActionPreference = 'Stop'

$models = @(
    'google/gemma-4-e4b',
    'nvidia/nemotron-3-nano-4b',
    'prism-ml/bonsai-27b',
    'qwen/qwen3-vl-8b'
)

foreach ($model in $models) {
    Write-Host "Downloading model: $model..."

    try {
        lms.exe get $model
    }
    catch {
        throw
    }
}
