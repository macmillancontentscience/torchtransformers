# luz callback works.

    Code
      fitted
    Output
      A `luz_module_fitted`
      -- Time ------------------------------------------------------------------------
      * Total time: 
    Warning <simpleWarning>
      argument is not numeric or logical: returning NA
    Output
      * Avg time per training batch: NA
      
      -- Results ---------------------------------------------------------------------
      Metrics observed in the last epoch.
      
      i Training:
      loss: 1.1151
      acc: 0
      
      -- Model -----------------------------------------------------------------------
      An `nn_module` containing 4,369,666 parameters.
      
      -- Modules ---------------------------------------------------------------------
      * bert: <BERT_pretrained> #4,369,408 parameters
      * linear: <nn_linear> #258 parameters

---

    Code
      luz_callback_bert_tokenize()
    Output
      <bert_tokenize_callback>
        Inherits from: <LuzCallback>
        Public:
          call: function (callback_nm) 
          clone: function (deep = FALSE) 
          initialize: function () 
          n_tokens: NULL
          on_fit_begin: function () 
          on_predict_begin: function () 
          set_ctx: function (ctx) 
          submodel_name: NULL
          verbose: TRUE

---

    Code
      luz_callback_bert_tokenize(submodel_name = "bert")
    Output
      <bert_tokenize_callback>
        Inherits from: <LuzCallback>
        Public:
          call: function (callback_nm) 
          clone: function (deep = FALSE) 
          initialize: function () 
          n_tokens: NULL
          on_fit_begin: function () 
          on_predict_begin: function () 
          set_ctx: function (ctx) 
          submodel_name: bert
          verbose: TRUE

---

    Code
      luz_callback_bert_tokenize(n_tokens = 32L)
    Output
      <bert_tokenize_callback>
        Inherits from: <LuzCallback>
        Public:
          call: function (callback_nm) 
          clone: function (deep = FALSE) 
          initialize: function () 
          n_tokens: 32
          on_fit_begin: function () 
          on_predict_begin: function () 
          set_ctx: function (ctx) 
          submodel_name: NULL
          verbose: TRUE

---

    Code
      luz_callback_bert_tokenize(verbose = FALSE)
    Output
      <bert_tokenize_callback>
        Inherits from: <LuzCallback>
        Public:
          call: function (callback_nm) 
          clone: function (deep = FALSE) 
          initialize: function () 
          n_tokens: NULL
          on_fit_begin: function () 
          on_predict_begin: function () 
          set_ctx: function (ctx) 
          submodel_name: NULL
          verbose: FALSE

