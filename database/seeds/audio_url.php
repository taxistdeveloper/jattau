<?php

declare(strict_types=1);

function seedAudioUrl(int $surahNumber, int $ayahNumber): string
{
    return sprintf(
        'https://everyayah.com/data/Alafasy_128kbps/%03d%03d.mp3',
        $surahNumber,
        $ayahNumber
    );
}
