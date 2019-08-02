# radio
MPD + MPC + Telegram bot radio stack in Docker, depends on python-telegram-bot, python-musicpd and mpddj

Before start change credentials for stream access in mpd.conf, and credentials for Telegram bot in config.py

Setcommands list example for BotFather:
* add - Add song by full path
* sample - Randomly list some songs
* status - Now playing
* stats - Songs quantity
* order - Order a song
* searchorder - Search and order first match song
* next - Skip current song
* history - Order history
* search - Search song
* searchadd - Search and add first match song
* playlist - Show current playlist
* list - List files (don't do this!)
* stream - Get stream address
* help - Show this help

Build with `docker-compose build`

Run with `docker-compose up`
