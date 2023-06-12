FROM python:3.9

COPY ./document_scanner /srv/www/document_scanner
COPY requirements.txt /srv/www/document_scanner
COPY Pipfile /srv/www/document_scanner
WORKDIR /srv/www/document_scanner
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y
RUN python -m pip install --upgrade pip
RUN pip install pipenv && pipenv lock && pipenv install --dev --system --deploy