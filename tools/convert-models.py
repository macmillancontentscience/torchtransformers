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
  "bert-tiny": "https://huggingface.co/google/bert_uncased_L-2_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-mini": "https://huggingface.co/google/bert_uncased_L-4_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-small": "https://huggingface.co/google/bert_uncased_L-4_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-medium": "https://huggingface.co/google/bert_uncased_L-8_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-L4H128": "https://huggingface.co/google/bert_uncased_L-4_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-L6H128": "https://huggingface.co/google/bert_uncased_L-6_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-L8H128": "https://huggingface.co/google/bert_uncased_L-8_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-L10H128": "https://huggingface.co/google/bert_uncased_L-10_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-L12H128": "https://huggingface.co/google/bert_uncased_L-12_H-128_A-2/resolve/main/pytorch_model.bin",
  "bert-L2H256": "https://huggingface.co/google/bert_uncased_L-2_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-L6H256": "https://huggingface.co/google/bert_uncased_L-6_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-L8H256": "https://huggingface.co/google/bert_uncased_L-8_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-L10H256": "https://huggingface.co/google/bert_uncased_L-10_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-L12H256": "https://huggingface.co/google/bert_uncased_L-12_H-256_A-4/resolve/main/pytorch_model.bin",
  "bert-L2H512": "https://huggingface.co/google/bert_uncased_L-2_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-L6H512": "https://huggingface.co/google/bert_uncased_L-6_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-L10H512": "https://huggingface.co/google/bert_uncased_L-10_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-L12H512": "https://huggingface.co/google/bert_uncased_L-12_H-512_A-8/resolve/main/pytorch_model.bin",
  "bert-L2H768": "https://huggingface.co/google/bert_uncased_L-2_H-768_A-12/resolve/main/pytorch_model.bin",
  "bert-L4H768": "https://huggingface.co/google/bert_uncased_L-4_H-768_A-12/resolve/main/pytorch_model.bin",
  "bert-L6H768": "https://huggingface.co/google/bert_uncased_L-6_H-768_A-12/resolve/main/pytorch_model.bin",
  "bert-L8H768": "https://huggingface.co/google/bert_uncased_L-8_H-768_A-12/resolve/main/pytorch_model.bin",
  "bert-L10H768": "https://huggingface.co/google/bert_uncased_L-10_H-768_A-12/resolve/main/pytorch_model.bin"
  "bert-L12H768": "https://huggingface.co/google/bert_uncased_L-12_H-768_A-12/resolve/main/pytorch_model.bin"
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
