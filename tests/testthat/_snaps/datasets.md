# dataset_bert works

    Code
      test_result
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result$token_types
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
      test_result$tokenized_text
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
      test_result$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

---

    Code
      test_result
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result$token_types
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
      test_result$tokenized_text
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
      test_result$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

---

    Code
      test_result
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result$token_types
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
      test_result$tokenized_text
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
      test_result$y
    Output
      torch_tensor
      [ CPULongType{0} ]

---

    Code
      test_result
    Output
      <bert_dataset>
        Inherits from: <dataset>
        Public:
          .getitem: function (index) 
          .length: function () 
          clone: function (deep = FALSE) 
          initialize: function (x, y = NULL, n_tokens = 128L) 
          token_types: torch_tensor, R7
          tokenized_text: torch_tensor, R7
          y: torch_tensor, R7

---

    Code
      test_result$token_types
    Output
      torch_tensor
      Columns 1 to 26 1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2
      
      Columns 27 to 32 2  2  2  2  2  2
       2  2  2  2  2  2
      [ CPULongType{2,32} ]

---

    Code
      test_result$tokenized_text
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
      test_result$y
    Output
      torch_tensor
       1
       2
      [ CPULongType{2} ]

