|%
+$  address  @t
+$  request  [who=@p amount=@t message=@t]
+$  id  [=address claimed=(unit ship)]
+$  transaction  
  $:  from=id
      to=id
      value=@t
      block=@t
      hash=@t
  ==
+$  signature
  $:  hancock=@t
      =ship
      address=@t
  ==
+$  action
  $%  [%change-address =address]
      [%find-address =ship]
      [%request =request]
      [%attest receiver=ship =signature]
      [%note hash=@t note=@t]
  ==
--