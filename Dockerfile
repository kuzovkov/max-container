FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

RUN apt-get update && \
    apt-get install -y x11vnc xvfb fluxbox wget wmctrl software-properties-common \
    psmisc net-tools mc htop xfce4 xfce4-goodies x11-apps dbus-x11 mesa-utils

RUN apt-get install -y sudo && \
    echo "maxuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/maxuser && \
    chmod 0440 /etc/sudoers.d/maxuser

#fix locales
RUN mkdir /var/lib/locales && \
    mkdir /var/lib/locales/supported.d && \
    touch /var/lib/locales/supported.d/ru && \
    echo "ru_RU.CP1251 CP1251" > /var/lib/locales/supported.d/ru && \
    apt-get install -y locales && \
    locale-gen

RUN apt-get install -y python-dev build-essential
RUN apt-get install -y python3-pip
RUN pip install --upgrade pip

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable

RUN sudo dpkg --add-architecture i386 && sudo apt update
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_FRONTEND teletype

# Копируем .deb Max Messenger
COPY MAX.deb /tmp/MAX.deb

# Устанавливаем Max Messenger
RUN apt-get update && apt-get install -y ./tmp/MAX.deb || true \
    && apt-get -f install -y \
    && rm -f /tmp/MAX.deb

# Add a user for running applications.
RUN useradd maxuser
RUN mkdir -p /home/maxuser && chown maxuser:maxuser /home/maxuser
COPY bootstrap.sh /

CMD '/bootstrap.sh'
