# dataset_bert_pretrained can tokenize after initialization.

    Code
      data_separate
    Output
      <bert_pretrained_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer_scheme = NULL, n_tokens = NULL) 
          tokenize: function (tokenizer_scheme, n_tokens) 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer: list
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
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer_scheme = NULL, n_tokens = NULL) 
          tokenize: function (tokenizer_scheme, n_tokens) 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer: list
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
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer_scheme = NULL, n_tokens = NULL) 
          tokenize: function (tokenizer_scheme, n_tokens) 
        Private:
          input_data: list
          processed_data: list
          tokenized: TRUE
          tokenizer: list
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
      

# dataset_bert works

    Code
      test_result_df
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer = tokenize_bert, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result_df$token_types
    Output
      torch_tensor
      Columns 1 to 26 1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 27 to 52 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 53 to 78 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 79 to 104 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 105 to 128 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      [ CPULongType{2,128} ]

---

    Code
      test_result_df$tokenized_text
    Output
      torch_tensor
      Columns 1 to 13  102  2071  3794   103  2146  2063   103     1     1     1     1     1     1
        102  2063  3794   103  2037  2179   103     1     1     1     1     1     1
      
      Columns 14 to 26    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 27 to 39    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 40 to 52    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 53 to 65    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 66 to 78    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 79 to 91    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 92 to 104    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 105 to 117    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 118 to 128    1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1
      [ CPULongType{2,128} ]

---

    Code
      test_result_df$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

---

    Code
      test_result_factor
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer = tokenize_bert, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result_factor$token_types
    Output
      torch_tensor
      Columns 1 to 26 1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 27 to 52 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 53 to 78 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 79 to 104 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 105 to 128 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      [ CPULongType{2,128} ]

---

    Code
      test_result_factor$tokenized_text
    Output
      torch_tensor
      Columns 1 to 13  102  2071  3794   103  2146  2063   103     1     1     1     1     1     1
        102  2063  3794   103  2037  2179   103     1     1     1     1     1     1
      
      Columns 14 to 26    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 27 to 39    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 40 to 52    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 53 to 65    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 66 to 78    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 79 to 91    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 92 to 104    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 105 to 117    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 118 to 128    1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1
      [ CPULongType{2,128} ]

---

    Code
      test_result_factor$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

---

    Code
      test_result_null
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer = tokenize_bert, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result_null$token_types
    Output
      torch_tensor
      Columns 1 to 26 1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 27 to 52 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 53 to 78 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 79 to 104 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 105 to 128 2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      [ CPULongType{2,128} ]

---

    Code
      test_result_null$tokenized_text
    Output
      torch_tensor
      Columns 1 to 13  102  2071  3794   103  2146  2063   103     1     1     1     1     1     1
        102  2063  3794   103  2037  2179   103     1     1     1     1     1     1
      
      Columns 14 to 26    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 27 to 39    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 40 to 52    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 53 to 65    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 66 to 78    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 79 to 91    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 92 to 104    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 105 to 117    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 118 to 128    1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1
      [ CPULongType{2,128} ]

---

    Code
      test_result_null$y
    Output
      torch_tensor
      [ CPULongType{0} ]

---

    Code
      test_result_tokens
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, tokenizer = tokenize_bert, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result_tokens$token_types
    Output
      torch_tensor
      Columns 1 to 26 1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 27 to 32 2  2  2  2  2  2
       2  2  2  2  2  2
      [ CPULongType{2,32} ]

---

    Code
      test_result_tokens$tokenized_text
    Output
      torch_tensor
      Columns 1 to 13  102  2071  3794   103  2146  2063   103     1     1     1     1     1     1
        102  2063  3794   103  2037  2179   103     1     1     1     1     1     1
      
      Columns 14 to 26    1     1     1     1     1     1     1     1     1     1     1     1     1
          1     1     1     1     1     1     1     1     1     1     1     1     1
      
      Columns 27 to 32    1     1     1     1     1     1
          1     1     1     1     1     1
      [ CPULongType{2,32} ]

---

    Code
      test_result_tokens$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

