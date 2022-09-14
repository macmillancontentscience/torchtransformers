# dataset_bert_pretrained can tokenize after initialization.

    Code
      data_separate
    Output
      <bert_pretrained_dataset>
        Inherits from: <dataset>
        Public:
          .getbatch: function (index) 
          .getitem: function (index) 
          .length: function () 
          .tokenize_for_model: function (model, n_tokens) 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, bert_type = NULL, tokenizer_scheme = NULL, 
          tokenize: function (tokenizer_scheme, n_tokens) 
          untokenize: function () 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer_metadata: list
          torch_data: list

---

    Code
      data_separate$.getitem(1)
    Output
      [[1]]
      [[1]]$token_ids
      torch_tensor
        102
       2071
       3794
        103
       2146
       2063
        103
          1
          1
          1
      [ CPULongType{10} ]
      
      [[1]]$token_type_ids
      torch_tensor
       1
       1
       1
       1
       2
       2
       2
       2
       2
       2
      [ CPULongType{10} ]
      
      
      [[2]]
      torch_tensor
      1
      [ CPULongType{} ]
      

# dataset_bert_pretrained can partially set tokenization info.

    Code
      data_with_scheme
    Output
      <bert_pretrained_dataset>
        Inherits from: <dataset>
        Public:
          .getbatch: function (index) 
          .getitem: function (index) 
          .length: function () 
          .tokenize_for_model: function (model, n_tokens) 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, bert_type = NULL, tokenizer_scheme = NULL, 
          tokenize: function (tokenizer_scheme, n_tokens) 
          untokenize: function () 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer_metadata: list
          torch_data: list

---

    Code
      data_with_scheme$.getitem(1)
    Output
      [[1]]
      [[1]]$token_ids
      torch_tensor
        102
       1790
       3088
        103
       4210
       1168
        103
          1
          1
          1
      [ CPULongType{10} ]
      
      [[1]]$token_type_ids
      torch_tensor
       1
       1
       1
       1
       2
       2
       2
       2
       2
       2
      [ CPULongType{10} ]
      
      
      [[2]]
      torch_tensor
      1
      [ CPULongType{} ]
      

# dataset_bert_pretrained can do it all in one go.

    Code
      data_tokenized
    Output
      <bert_pretrained_dataset>
        Inherits from: <dataset>
        Public:
          .getbatch: function (index) 
          .getitem: function (index) 
          .length: function () 
          .tokenize_for_model: function (model, n_tokens) 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, bert_type = NULL, tokenizer_scheme = NULL, 
          tokenize: function (tokenizer_scheme, n_tokens) 
          untokenize: function () 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer_metadata: list
          torch_data: list

---

    Code
      data_tokenized$.getitem(1)
    Output
      [[1]]
      [[1]]$token_ids
      torch_tensor
        102
       2071
       3794
        103
       2146
       2063
        103
          1
          1
          1
      [ CPULongType{10} ]
      
      [[1]]$token_type_ids
      torch_tensor
       1
       1
       1
       1
       2
       2
       2
       2
       2
       2
      [ CPULongType{10} ]
      
      
      [[2]]
      torch_tensor
      1
      [ CPULongType{} ]
      

