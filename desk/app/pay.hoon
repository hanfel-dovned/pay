/-  *pay
/+  dbug, default-agent, server, schooner, ethereum, naive
/*  ui  %html  /app/pay/html
::
|%
+$  versioned-state  $%(state-0)
+$  state-0  
  $:  %0
      wallet=address
      ledger=(list [transaction note=@t])
      addresses=(map ship [=address retrieved=@da])
      attested=(map address ship)
      requests=(map @da request)
      outgoing=(map @da request)
      previous=[block=@t from=?]
  ==
+$  card  card:agent:gall
--
::
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
::
=<
|_  =bowl:gall
+*  this  .
    def  ~(. (default-agent this %|) bowl)
    hc   ~(. +> [bowl ~])
::
++  on-init
  ^-  (quip card _this)
  =^  cards  state  abet:init:hc
  [cards this]
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  =vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 vase))]
::
++  on-poke
  |=  =cage
  ^-  (quip card _this)
  =^  cards  state  abet:(poke:hc cage)
  [cards this]
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  [~ ~]
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  =^  cards  state  abet:(agent:hc [wire sign])
  [cards this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  =^  cards  state  abet:(arvo:hc [wire sign-arvo])
  [cards this]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  =^  cards  state  abet:(watch:hc path)
  [cards this]
::
++  on-fail   on-fail:def
++  on-leave  on-leave:def
--
::
|_  [=bowl:gall deck=(list card)]
+*  that  .
::
++  emit  |=(=card that(deck [card deck]))
++  emil  |=(lac=(list card) that(deck (welp lac deck)))
++  abet  ^-((quip card _state) [(flop deck) state])
::
++  init
  ^+  that
  =.  wallet  'none'
  =.  previous  ['0x0' %.n]
  %-  emit
  :*  %pass   /eyre/connect   
      %arvo  %e  %connect
      `/apps/pay  %pay
  ==
::
::  Create an Iris card containing an
::  HTTP request to Alchemy, asking
::  for transactions either from this address
::  or to this address, starting from block.
++  alchemy-card
  |=  [=address block=@t from=?]
  ^-  card
  :*  %pass  /alchemy/[address]  %arvo  %i
      %request  (alchemy-request address block from) 
      *outbound-config:iris
  ==
::
::  Create an HTTP request to Alchemy.
++  alchemy-request
  |=  [=address block=@t from=?]
  ^-  request:http
  :*  %'POST'
      'https://eth-sepolia.g.alchemy.com/v2/Qv7RwrBl83LReBuiT_E8KcAjEkoe4yd6'
      :~  ['Content-Type' 'application/json']
          ['accept' 'application/json']
      ==
  ::
      :-  ~
      %-  json-to-octs:server
      ^-  json
      %-  pairs:enjs:format
      :~  [%id n+'1']
          [%jsonrpc s+'2.0']
          [%method s+'alchemy_getAssetTransfers']
      ::
          :-  %params            
          :-  %a
          :~  %-  pairs:enjs:format
              :~  ['fromBlock' s+block]
                  ['toBlock' s+'latest']
                  ['category' [%a [[%s 'external'] ~]]]
                  ['order' s+'asc']
                  ['withMetadata' b+%.n]
                  ['maxCount' s+'0x3e8'] :: 0x3e8 = 1000 = max allowed
                  ?:  from  :: can only include one of these at a time
                    ['fromAddress' [%s address]]
                  ['toAddress' [%s address]]
              ==
          ==
      ==
  ==
::
::  Handle a response from Alchemy.
++  arvo
  |=  [=wire sign=sign-arvo]
  ^+  that
    ?.  ?=([%iris %http-response *] sign)  that
  =/  response  client-response.sign
  ?+    -.response  that
      %finished
    =/  mime  (need full-file.response)
    =/  =json  (need (de:json:html q.data.mime))
    =/  unclaimed=(list [from=address to=address value=@t block=@t hash=@t])
      (dejs-response json)
    =/  claimed  (append-attestations unclaimed)
    =/  withnotes  (turn claimed |=(=transaction [transaction '']))
    =.  ledger  (weld ledger withnotes)
    ::  We need to check the same range twice, 
    ::  once each for %.n and %.y
    ?~  ledger  that
    =.  previous
      ?:  from.previous
        [block:(rear ledger) %.n]
      [block.previous %.y]
    that
  ==
::
::  If a ship attested control of an address, 
::  label that address in the transaction.
++  append-attestations
  |=  unclaimed=(list [from=address to=address value=@t block=@t hash=@t])
  ^-  (list transaction)
  %+  turn
    unclaimed
  |=  [from=address to=address value=@t block=@t hash=@t]
  ^-  transaction
  :*  :-  from
      (~(get by attested) from)
  ::
      :-  to
      (~(get by attested) to)
  ::
      value
      block
      hash
  ==
::
::  Return our address to a ship that subscribes to us.
++  watch
  |=  =path
  ^+  that
  ?+    path  that
      [%http-response *]
    that
  ::
      [%address ~]
    %-  emil
    :~  [%give %kick ~[/address] ~]
        :*  %give  %fact  ~  
            %pay-address
            !>(`address`wallet)
        ==
    ==
  ==
::
::  Get a response from another user with their address.
::  Save it, along with the time.
++  agent
  |=  [=wire =sign:agent:gall]
  ?+    wire  that
      [%addresses ~]
    ?+    -.sign  that
        %fact
      ?+    p.cage.sign  that
          %pay-address
        =/  =address  !<(address q.cage.sign)
        =.  addresses  
          (~(put by addresses) src.bowl [address now.bowl])
        that
      ==
    ==
  ==
:: 
++  poke
  |=  =cage
  ^+  that
  ?+    -.cage  !!
      %handle-http-request
    (handle-http !<([@ta =inbound-request:eyre] +.cage))
  ::
  ::  Validate signature and, if successful, 
  ::  save address-to-ship mapping.
      %pay-signature
    =/  =signature  !<(signature +.cage)
    ?.  =(ship.signature src.bowl)
      ~&  >>>  'Liar! This poke did not come from <ship.signature>!'
      that
    ?.  (validate signature)
      ~&  >>>  'Liar! Signature failed to validate!'
      that
    ~&  >  'Validated signature.'
    =.  attested  
      (~(put by attested) address.signature ship.signature)
    that
  ::
  ::  Receive a payment request from poker.
      %pay-request
    =/  =request  !<(request +.cage)
    =.  requests
      (~(put by requests) now.bowl [src.bowl amount.request message.request])
    that
  ==
::
++  handle-http
  |=  [eyre-id=@ta =inbound-request:eyre]
  ^+  that
  ?>  =(src.bowl our.bowl)
  =/  ,request-line:server
    (parse-request-line:server url.request.inbound-request)
  =+  send=(cury response:schooner eyre-id)
  ::
  ?+    method.request.inbound-request
    (emil (flop (send [405 ~ [%stock ~]])))
    ::
      %'GET'
    =.  that  (emit (alchemy-card [wallet block.previous %.n]))  :: XX hack
    %-  emil  %-  flop  %-  send
    ?+    site  [404 ~ [%plain "404 - Not Found"]]
    ::
        [%apps %pay ~]
      [200 ~ [%html ui]]
    ::
        [%apps %pay %state ~]
      [200 ~ [%json enjs-state]]
    ::
    ::  If we just now retrieved another user's address,
    ::  respond with it. Otherwise, respond 'waiting'.
        [%apps %pay %get-address @ ~]
      =/  =ship  (slav %p +30:site)
      =/  log  (~(get by addresses) ship)
      =;  response
        [200 ~ [%json [%o (malt response)]]]
      ?~  log
        ['status' [%s 'waiting']]~
      =/  cutoff=@da  (sub now.bowl ~m5)
      ?:  (lth retrieved.u.log cutoff)
        ['status' [%s 'waiting']]~
      ['address' [%s address.u.log]]~
    ==
  ::
      %'POST'
    ?+    site  
        (emil (flop (send [404 ~ [%plain "404 - Not Found"]])))
    ::
        [%apps %pay %action ~]
      ?~  body.request.inbound-request  !!
      =/  jon=(unit json)
        (de:json:html q.u.body.request.inbound-request)
      =/  =action  (dejs-action (need jon))
      ?-    -.action
      ::
      ::  Edit my wallet address.
      ::  Delete ledger and check Alchemy.
          %change-address
        =.  wallet  address.action
        =.  ledger  ~
        %-  emil
        %+  weld
          (flop (send [200 ~ [%json [%s 'waiting']]]))
        :~  %-  alchemy-card
            [wallet block.previous %.n]
          ::
          ::  XX Send a card to Behn to start the retrieval timer.
          ::  Have Behn alternate between from=%.n and from=%.y.
          ::
        ==
      ::
      ::  Retrieve the wallet address of the given user.
          %find-address
        =/  =ship  ship.action
        %-  emil
        %+  weld
          (flop (send [200 ~ [%json [%s 'waiting']]]))
        :~  ^-  card
            :*  %pass  /addresses  %agent
                [ship %pay]  %watch  /address
            ==
        ==
      ::
      ::  Poke requestee with a payment request
      ::  and save that outgoing request.
          %request
        =.  outgoing
          (~(put by outgoing) now.bowl request.action)
        %-  emil
        %+  weld
          (flop (send [200 ~ [%json [%s 'sent']]]))
        :~  ^-  card
            :*  %pass  /requests  %agent
                [who.request.action %pay]  %poke
                %pay-request  !>(request.action)
            ==
        ==
      ::
      ::  Poke the receiver of the transaction with
      ::  a messaged signed by the sending address.
          %attest
        %-  emil
        %+  weld
          (flop (send [200 ~ [%json [%s 'sent']]]))
        :~  ^-  card
            :*  %pass  /signatures  %agent
                [receiver.action %pay]  %poke
                %pay-signature  !>(signature.action)
            ==
        ==
      ::
      ::  Update the note for a transaction.
          %note
        %=  that
          ledger
          %+  turn
            ledger
          |=  [=transaction note=@t]
          ?:  =(hash.action hash.transaction)
            [transaction note.action]
          [transaction note]
        ==
      ==
    ==
  ==
::
++  enjs-state
  =,  enjs:format
  ^-  json
  %-  pairs
  :~  [%our [%s (scot %p our.bowl)]]
      [%address [%s wallet]]
      ::
      :-  %requests
      :-  %a
      %+  turn
        ~(tap by requests)
      |=  [key=@da [from=@p amount=@t text=@t]]
      %-  pairs
      :~  [%key (time key)]
          [%from (ship from)]
          [%amount [%s amount]]
          [%text [%s text]]
      ==
      ::
      :-  %ledger
      :-  %a
      %+  turn
        ledger
      |=  [[from=id to=id value=@t block=@t hash=@t] note=@t]
      %-  pairs
      :~  [%from-address [%s address.from]]
          [%from-ship ?~(claimed.from ~ [%s (scot %p u.claimed.from)])]
          [%to-address [%s address.to]]
          [%to-ship ?~(claimed.to ~ [%s (scot %p u.claimed.to)])]
          [%value [%s value]]
          [%block [%s block]]
          [%hash [%s hash]]
          [%note [%s note]]
      ==
  ==
::
::  Turn an alchemy response into a list of
::  unclaimed transactions.
++  dejs-response
  |=  jon=json
  =,  dejs:format
  ^-  (list [=address =address value=@t block=@t hash=@t])
  %.  jon
  %-  ot
  :~  :-  %result
      %-  ot
      :~  :-  %transfers
          %-  ar
          %-  ot
          :~  from+so
              to+so
              value+no
              ['blockNum' so]
              hash+so
          ==
      ==
  ==
::
++  dejs-action
  =,  dejs:format
  |=  jon=json
  ^-  action
  %.  jon
  %-  of
  :~  [%change-address so]
      [%find-address (se %p)]
      [%request (ot [who+(se %p) amount+so message+so ~])]
      [%note (ot [hash+so note+so ~])]
      :-  %attest
      %-  ot
      :~  [%receiver (se %p)]
          :-  %signed
          %-  ot
          :~  [%signature so]
              [%ship (se %p)]
              [%address so]
          ==
      ==
  ==
::
::  Encode the signed message back into JSON
::  for validation.
++  enjs-message
  =,  enjs:format
  |=  =signature
  ^-  json
  ::  Make sure the frontend orders this JSON the same
  ::  as ++pairs output, or validation will fail.
  ::  Input list order does not matter for ++pairs.
  %-  pairs
  :~  [%address [%s address.signature]]
      [%ship [%s (scot %p ship.signature)]]
  ==
::
::  Validate that from.signature = signer of sig.signature
++  validate
  |=  =signature
  ^-  ?
  =/  addy  (from-tape (trip address.signature))
  =/  cock  (from-tape (trip hancock.signature))
  =/  note=@uvI
    =/  octs
      %-  as-octs:mimes:html
      %-  en:json:html
      (enjs-message signature)
    %-  keccak-256:keccak:crypto
    %-  as-octs:mimes:html
    ;:  (cury cat 3)
      '\19Ethereum Signed Message:\0a'
      (crip (a-co:co p.octs))
      q.octs
    ==
  ?.  &(=(20 (met 3 addy)) =(65 (met 3 cock)))  %.n
  =/  r  (cut 3 [33 32] cock)
  =/  s  (cut 3 [1 32] cock)
  =/  v=@
    =+  v=(cut 3 [0 1] cock)
    ?+  v  !!
      %0   0
      %1   1
      %27  0
      %28  1
    ==
  ?.  |(=(0 v) =(1 v))  %.n
  =/  xy
    (ecdsa-raw-recover:secp256k1:secp:crypto note v r s)
  =/  pub  :((cury cat 3) y.xy x.xy 0x4)
  =/  add  (address-from-pub:key:ethereum pub)
  =(addy add)
::
++  from-tape
  |=(h=tape ^-(@ux (scan h ;~(pfix (jest '0x') hex))))
--