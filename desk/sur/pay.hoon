|%
+$  address  @t
+$  request  [who=@p amount=@t message=@t] :: For the same request, the receiver and sender use opposite `who`s
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
  $%  [%change-alchemy url=@t]
      [%change-address =address]
      [%find-address =ship]
      [%request =request]
      [%attest receiver=ship =signature]
      [%fulfill-request key=@da]
      [%note hash=@t note=@t]
  ==
--