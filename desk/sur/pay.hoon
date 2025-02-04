|%
+$  address  @t
+$  request  [who=@p amount=@t message=@t]
+$  id  [=address claimed=(unit ship)]
+$  transaction  
  $:  from=id
      to=id
      value=@t
  ==
+$  signature
  $:  hancock=@t
      =ship
      address=@t
  ==
--