# simplify_bert_token_list returns expected dimensions

    Code
      test_result
    Output
           [,1] [,2] [,3]
      [1,]    1    2    3
      [2,]    2    3    4

# increment_list_index does what it says

    Code
      increment_list_index(list(1:3, 2:6))
    Output
      [[1]]
      [1] 2 3 4
      
      [[2]]
      [1] 3 4 5 6 7
      

# tokenize_bert returns data in the expected shapes

    Code
      tokenize_bert(text = to_tokenize, n_tokens = 6)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6]
      [1,]  102 2020 2743 2008 3244  103
      [2,]  102 1038 2461 2743 1013  103
      [3,]  102 2179 2029 1013  103    1
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6]
      [1,]    1    1    1    1    1    1
      [2,]    1    1    1    1    1    1
      [3,]    1    1    1    1    1    1
      

---

    Code
      tokenize_bert(text = to_tokenize, n_tokens = 6, simplify = FALSE)
    Output
      $token_ids
      $token_ids[[1]]
        [CLS]      an example    with   quite   [SEP] 
          102    2020    2743    2008    3244     103 
      
      $token_ids[[2]]
        [CLS]       a   short example       .   [SEP] 
          102    1038    2461    2743    1013     103 
      
      $token_ids[[3]]
        [CLS] another     one       .   [SEP]   [PAD] 
          102    2179    2029    1013     103       1 
      
      
      $token_type_ids
      $token_type_ids[[1]]
      [1] 1 1 1 1 1 1
      
      $token_type_ids[[2]]
      [1] 1 1 1 1 1 1
      
      $token_type_ids[[3]]
      [1] 1 1 1 1 1 1
      
      

---

    Code
      tokenize_bert(text = to_tokenize, n_tokens = 6, increment_index = FALSE)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6]
      [1,]  101 2019 2742 2007 3243  102
      [2,]  101 1037 2460 2742 1012  102
      [3,]  101 2178 2028 1012  102    0
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6]
      [1,]    1    1    1    1    1    1
      [2,]    1    1    1    1    1    1
      [3,]    1    1    1    1    1    1
      

---

    Code
      tokenize_bert(text = to_tokenize, n_tokens = 6, simplify = FALSE,
        increment_index = FALSE)
    Output
      $token_ids
      $token_ids[[1]]
        [CLS]      an example    with   quite   [SEP] 
          101    2019    2742    2007    3243     102 
      
      $token_ids[[2]]
        [CLS]       a   short example       .   [SEP] 
          101    1037    2460    2742    1012     102 
      
      $token_ids[[3]]
        [CLS] another     one       .   [SEP]   [PAD] 
          101    2178    2028    1012     102       0 
      
      
      $token_type_ids
      $token_type_ids[[1]]
      [1] 1 1 1 1 1 1
      
      $token_type_ids[[2]]
      [1] 1 1 1 1 1 1
      
      $token_type_ids[[3]]
      [1] 1 1 1 1 1 1
      
      

