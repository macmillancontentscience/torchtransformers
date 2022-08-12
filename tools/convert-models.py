import torch
import requests
from google.cloud import storage
import os

version = "1"

models = {
  "bert-base-uncased": "https://huggingface.co/bert-base-uncased/resolve/main/pytorch_model.bin",
  "bert-base-cased": "https://huggingface.co/bert-base-cased/resolve/main/pytorch_model.bin",
  "bert-large-uncased": "https://huggingface.co/bert-large-uncased/resolve/main/pytorch_model.bin",
  "bert-large-cased": "https://huggingface.co/bert-large-cased/resolve/main/pytorch_model.bin",
  "bert-tiny": "https://huggingface.co/prajjwal1/bert-tiny/resolve/main/pytorch_model.bin",
  "bert-mini": "https://huggingface.co/prajjwal1/bert-mini/resolve/main/pytorch_model.bin",
  "bert-small": "https://huggingface.co/prajjwal1/bert-small/resolve/main/pytorch_model.bin",
  "bert-medium": "https://huggingface.co/prajjwal1/bert-medium/resolve/main/pytorch_model.bin",
  "bert-L4H128": "https://huggingface.co/google/bert_uncased_L-4_H-128_A-2/blob/main/pytorch_model.bin"
}

def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    # bucket_name = "your-bucket-name"
    # source_file_name = "local/path/to/file"
    # destination_blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_filename(source_file_name)

    print(
        "File {} uploaded to {}.".format(
            source_file_name, destination_blob_name
        )
    )

def download_file (url, filename):
  r = requests.get(url, allow_redirects=True, stream=True)
  with open(filename, 'wb') as f:
    for chunk in r.iter_content(chunk_size=1024): 
        if chunk: f.write(chunk)


for name, url in models.items():
  fpath = "weights.pt"
  download_file(url, fpath)
  d = dict(torch.load(fpath))
  
  torch.save(d, fpath, _use_new_zipfile_serialization=True)
  upload_blob(
    "torchtransformers-models",
    fpath,
    name + "/v" + version + "/" + fpath 
  )
