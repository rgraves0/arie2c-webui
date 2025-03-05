FROM ubuntu:20.04

# Timezone ကို ကြိုတင်သတ်မှတ်ပါ (non-interactive ဖြစ်အောင်)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Yangon" > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Yangon /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# လိုအပ်တဲ့ packages ထည့်သွင်းပါ
RUN apt-get update && apt-get install -y aria2 git nginx && rm -rf /var/lib/apt/lists/*

# webui-aria2 ကို clone လုပ်ပါ
RUN git clone https://github.com/ziahamza/webui-aria2.git /var/www/html/webui-aria2

# Nginx config ပြင်ဆင်ပါ
RUN echo "server { \
    listen 80; \
    root /var/www/html/webui-aria2; \
    index index.html; \
    }" > /etc/nginx/sites-available/default

# Aria2 config ဖန်တီးပါ
RUN mkdir -p /aria2 && echo "dir=/aria2/downloads\nenable-rpc=true\nrpc-listen-all=true\nrpc-listen-port=6800\nrpc-secret=admin123" > /aria2/aria2.conf

# Download ဖိုဒါ ဖန်တီးပါ
RUN mkdir -p /aria2/downloads

# Start script ကို သေချာဖန်တီးပါ
RUN echo -e "#!/bin/bash\naria2c --conf-path=/aria2/aria2.conf &\nnginx -g 'daemon off;'" > /start.sh && \
    chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
