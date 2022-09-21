# Weights process as expected.

    Code
      .concatenate_qkv_weights(state_dict)
    Output
      $bert.encoder.layer.0.attention.self.in_proj_weight
      torch_tensor
       1
       2
       3
       1
       2
       3
       1
       2
       3
      [ CPULongType{9} ]
      
      $bert.encoder.layer.0.attention.self.in_proj_bias
      torch_tensor
       1
       2
       3
       1
       2
       3
       1
       2
       3
      [ CPULongType{9} ]
      

---

    Code
      .rename_state_dict_variables(state_dict)
    Output
      $encoder.layer.0.attention.self.query.weight
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      
      $encoder.layer.0.attention.self.query.bias
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      
      $encoder.layer.0.attention.self.key.weight
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      
      $encoder.layer.0.attention.self.key.bias
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      
      $encoder.layer.0.attention.self.value.weight
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      
      $encoder.layer.0.attention.self.value.bias
      torch_tensor
       1
       2
       3
      [ CPULongType{3} ]
      

