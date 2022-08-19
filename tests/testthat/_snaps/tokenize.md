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
      
      $token_names
           [,1]    [,2]      [,3]      [,4]      [,5]    [,6]   
      [1,] "[CLS]" "an"      "example" "with"    "quite" "[SEP]"
      [2,] "[CLS]" "a"       "short"   "example" "."     "[SEP]"
      [3,] "[CLS]" "another" "one"     "."       "[SEP]" "[PAD]"
      

---

    Code
      tokenize_bert(text = as.list(to_tokenize), n_tokens = 6)
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
      
      $token_names
           [,1]    [,2]      [,3]      [,4]      [,5]    [,6]   
      [1,] "[CLS]" "an"      "example" "with"    "quite" "[SEP]"
      [2,] "[CLS]" "a"       "short"   "example" "."     "[SEP]"
      [3,] "[CLS]" "another" "one"     "."       "[SEP]" "[PAD]"
      

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
      
      $token_names
           [,1]    [,2]      [,3]      [,4]      [,5]    [,6]   
      [1,] "[CLS]" "an"      "example" "with"    "quite" "[SEP]"
      [2,] "[CLS]" "a"       "short"   "example" "."     "[SEP]"
      [3,] "[CLS]" "another" "one"     "."       "[SEP]" "[PAD]"
      

# tokenizing works for 2-segment sequences

    Code
      tokenize_bert(to_tokenize, to_tokenize)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13] [,14]
      [1,]  102 2024 2004 1038 7100 6252 1013  103 2024  2004  1038  7100  6252  1013
      [2,]  102 2024 2004 2179 1011 2937 7100 6252 1013   103  2024  2004  2179  1011
           [,15] [,16] [,17] [,18] [,19] [,20] [,21] [,22] [,23] [,24] [,25] [,26]
      [1,]   103     1     1     1     1     1     1     1     1     1     1     1
      [2,]  2937  7100  6252  1013   103     1     1     1     1     1     1     1
           [,27] [,28] [,29] [,30] [,31] [,32] [,33] [,34] [,35] [,36] [,37] [,38]
      [1,]     1     1     1     1     1     1     1     1     1     1     1     1
      [2,]     1     1     1     1     1     1     1     1     1     1     1     1
           [,39] [,40] [,41] [,42] [,43] [,44] [,45] [,46] [,47] [,48] [,49] [,50]
      [1,]     1     1     1     1     1     1     1     1     1     1     1     1
      [2,]     1     1     1     1     1     1     1     1     1     1     1     1
           [,51] [,52] [,53] [,54] [,55] [,56] [,57] [,58] [,59] [,60] [,61] [,62]
      [1,]     1     1     1     1     1     1     1     1     1     1     1     1
      [2,]     1     1     1     1     1     1     1     1     1     1     1     1
           [,63] [,64]
      [1,]     1     1
      [2,]     1     1
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12] [,13] [,14]
      [1,]    1    1    1    1    1    1    1    1    2     2     2     2     2     2
      [2,]    1    1    1    1    1    1    1    1    1     1     2     2     2     2
           [,15] [,16] [,17] [,18] [,19] [,20] [,21] [,22] [,23] [,24] [,25] [,26]
      [1,]     2     2     2     2     2     2     2     2     2     2     2     2
      [2,]     2     2     2     2     2     2     2     2     2     2     2     2
           [,27] [,28] [,29] [,30] [,31] [,32] [,33] [,34] [,35] [,36] [,37] [,38]
      [1,]     2     2     2     2     2     2     2     2     2     2     2     2
      [2,]     2     2     2     2     2     2     2     2     2     2     2     2
           [,39] [,40] [,41] [,42] [,43] [,44] [,45] [,46] [,47] [,48] [,49] [,50]
      [1,]     2     2     2     2     2     2     2     2     2     2     2     2
      [2,]     2     2     2     2     2     2     2     2     2     2     2     2
           [,51] [,52] [,53] [,54] [,55] [,56] [,57] [,58] [,59] [,60] [,61] [,62]
      [1,]     2     2     2     2     2     2     2     2     2     2     2     2
      [2,]     2     2     2     2     2     2     2     2     2     2     2     2
           [,63] [,64]
      [1,]     2     2
      [2,]     2     2
      
      $token_names
           [,1]    [,2]   [,3] [,4]      [,5]     [,6]       [,7]     [,8]      
      [1,] "[CLS]" "this" "is" "a"       "sample" "sentence" "."      "[SEP]"   
      [2,] "[CLS]" "this" "is" "another" ","      "longer"   "sample" "sentence"
           [,9]   [,10]   [,11]  [,12]    [,13]      [,14] [,15]    [,16]   
      [1,] "this" "is"    "a"    "sample" "sentence" "."   "[SEP]"  "[PAD]" 
      [2,] "."    "[SEP]" "this" "is"     "another"  ","   "longer" "sample"
           [,17]      [,18]   [,19]   [,20]   [,21]   [,22]   [,23]   [,24]   [,25]  
      [1,] "[PAD]"    "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
      [2,] "sentence" "."     "[SEP]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
           [,26]   [,27]   [,28]   [,29]   [,30]   [,31]   [,32]   [,33]   [,34]  
      [1,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
      [2,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
           [,35]   [,36]   [,37]   [,38]   [,39]   [,40]   [,41]   [,42]   [,43]  
      [1,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
      [2,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
           [,44]   [,45]   [,46]   [,47]   [,48]   [,49]   [,50]   [,51]   [,52]  
      [1,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
      [2,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
           [,53]   [,54]   [,55]   [,56]   [,57]   [,58]   [,59]   [,60]   [,61]  
      [1,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
      [2,] "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]" "[PAD]"
           [,62]   [,63]   [,64]  
      [1,] "[PAD]" "[PAD]" "[PAD]"
      [2,] "[PAD]" "[PAD]" "[PAD]"
      
      attr(,"class")
      [1] "bert_tokens" "list"       

---

    Code
      tokenize_bert(to_tokenize, to_tokenize, n_tokens = 11)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11]
      [1,]  102 2024 2004 1038 7100  103 2024 2004 1038  7100   103
      [2,]  102 2024 2004 2179 1011  103 2024 2004 2179  1011   103
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11]
      [1,]    1    1    1    1    1    1    2    2    2     2     2
      [2,]    1    1    1    1    1    1    2    2    2     2     2
      
      $token_names
           [,1]    [,2]   [,3] [,4]      [,5]     [,6]    [,7]   [,8] [,9]     
      [1,] "[CLS]" "this" "is" "a"       "sample" "[SEP]" "this" "is" "a"      
      [2,] "[CLS]" "this" "is" "another" ","      "[SEP]" "this" "is" "another"
           [,10]    [,11]  
      [1,] "sample" "[SEP]"
      [2,] ","      "[SEP]"
      
      attr(,"class")
      [1] "bert_tokens" "list"       

---

    Code
      tokenize_bert(to_tokenize, to_tokenize, n_tokens = 10)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
      [1,]  102 2024 2004 1038 7100  103 2024 2004 1038   103
      [2,]  102 2024 2004 2179 1011  103 2024 2004 2179   103
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
      [1,]    1    1    1    1    1    1    2    2    2     2
      [2,]    1    1    1    1    1    1    2    2    2     2
      
      $token_names
           [,1]    [,2]   [,3] [,4]      [,5]     [,6]    [,7]   [,8] [,9]     
      [1,] "[CLS]" "this" "is" "a"       "sample" "[SEP]" "this" "is" "a"      
      [2,] "[CLS]" "this" "is" "another" ","      "[SEP]" "this" "is" "another"
           [,10]  
      [1,] "[SEP]"
      [2,] "[SEP]"
      
      attr(,"class")
      [1] "bert_tokens" "list"       

---

    Code
      tokenize_bert(to_tokenize, rev(to_tokenize), n_tokens = 10)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
      [1,]  102 2024 2004 1038 7100  103 2024 2004 2179   103
      [2,]  102 2024 2004 2179 1011  103 2024 2004 1038   103
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
      [1,]    1    1    1    1    1    1    2    2    2     2
      [2,]    1    1    1    1    1    1    2    2    2     2
      
      $token_names
           [,1]    [,2]   [,3] [,4]      [,5]     [,6]    [,7]   [,8] [,9]     
      [1,] "[CLS]" "this" "is" "a"       "sample" "[SEP]" "this" "is" "another"
      [2,] "[CLS]" "this" "is" "another" ","      "[SEP]" "this" "is" "a"      
           [,10]  
      [1,] "[SEP]"
      [2,] "[SEP]"
      
      attr(,"class")
      [1] "bert_tokens" "list"       

---

    Code
      tokenize_bert(to_tokenize, rev(to_tokenize), n_tokens = 11)
    Output
      $token_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11]
      [1,]  102 2024 2004 1038 7100  103 2024 2004 2179  1011   103
      [2,]  102 2024 2004 2179 1011  103 2024 2004 1038  7100   103
      
      $token_type_ids
           [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11]
      [1,]    1    1    1    1    1    1    2    2    2     2     2
      [2,]    1    1    1    1    1    1    2    2    2     2     2
      
      $token_names
           [,1]    [,2]   [,3] [,4]      [,5]     [,6]    [,7]   [,8] [,9]     
      [1,] "[CLS]" "this" "is" "a"       "sample" "[SEP]" "this" "is" "another"
      [2,] "[CLS]" "this" "is" "another" ","      "[SEP]" "this" "is" "a"      
           [,10]    [,11]  
      [1,] ","      "[SEP]"
      [2,] "sample" "[SEP]"
      
      attr(,"class")
      [1] "bert_tokens" "list"       

