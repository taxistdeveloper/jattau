<?php

return [
    'openai_api_key' => $_ENV['OPENAI_API_KEY'] ?? '',
    'whisper_model' => $_ENV['OPENAI_WHISPER_MODEL'] ?? 'whisper-1',
    'gpt_model' => $_ENV['OPENAI_GPT_MODEL'] ?? 'gpt-4o-mini',
    'whisper_url' => 'https://api.openai.com/v1/audio/transcriptions',
    'chat_url' => 'https://api.openai.com/v1/chat/completions',
];
