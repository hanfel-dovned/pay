/-  *pay
/+  dbug, default-agent, server, schooner
/*  ui  %html  /app/pay/html
::
|%
+$  versioned-state  $%(state-0)
+$  state-0  
  $:  %0
      wallet=address
      ledger=(list transaction)
      addresses=(map ship [=address retrieved=@da])
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
  =.  wallet  '0xda2701e7832da518054d6cc727b28169a36acb2f'
  %-  emil
  :~  %-  alchemy-card
      [wallet %.n]
  ::
      ::  XX Send a card to Behn to start the retrieval timer.
      ::  Have Behn alternate between from=%.n and from=%.y.
  ::
      :*  %pass   /eyre/connect   
          %arvo  %e  %connect
          `/apps/pay  %pay
      ==
  ==
::
::  Create an Iris card containing an
::  HTTP requests to Alchemy, asking
::  for transactions either from this address
::  or to this address.
++  alchemy-card
  |=  [=address from=?]
  ^-  card
  :*  %pass  /alchemy/[address]  %arvo  %i
      %request  (alchemy-request address from) 
      *outbound-config:iris
  ==
::
::  Create an HTTP request to Alchemy.
++  alchemy-request
  |=  [=address from=?]
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
              :~  ['fromBlock' s+'0x0']  :: XX shouldn't start from 0x0 every time
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
::  Handle a response from Alchemy
++  arvo
  |=  [=wire sign=sign-arvo]
  ^+  that
    ?.  ?=([%iris %http-response *] sign)  that
  =/  =address  +6:wire
  =/  response  client-response.sign
  ?+    -.response  that
      %finished
    =/  mime  (need full-file.response)
    =/  =json  (need (de:json:html q.data.mime))
    =/  transactions  (dejs-response json)
    =.  ledger  transactions
    that
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
    %-  emit
    :*  %give  %fact  ~  
        %pay-address
        !>(`address`wallet)
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
  ==
::
++  handle-http
  |=  [eyre-id=@ta =inbound-request:eyre]
  ^+  that
  =/  ,request-line:server
    (parse-request-line:server url.request.inbound-request)
  =+  send=(cury response:schooner eyre-id)
  ::
  ?+    method.request.inbound-request
    (emil (flop (send [405 ~ [%stock ~]])))
    ::
      %'POST'
    ?+    site  
      (emil (flop (send [404 ~ [%plain "404 - Not Found"]])))
    ::
    ::  Retrieve the wallet address of the user
    ::  specified in the URL.
        [%apps %pay %find-address @ ~]
      =/  =ship  (slav %p +30:site)
      %-  emil
      %+  weld
        (flop (send [200 ~ [%json [%s 'waiting']]]))
      :~  ^-  card
          :*  %pass  /addresses  %agent
              [ship %pay]  %watch  /address
          ==
      ==
    ==
    ::
      %'GET'
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
  ==
::
++  enjs-state
  =,  enjs:format
  ^-  json
  %-  pairs
  :~  [%address [%s wallet]]
      :-  %ledger
      :-  %a
      %+  turn
        ledger
      |=  [from=@t to=@t value=@t]
      %-  pairs
      :~  [%from [%s from]]
          [%to [%s to]]
          [%value [%s value]]
      ==
  ==
::
++  dejs-response
  |=  jon=json
  =,  dejs:format
  ^-  (list transaction)
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
          ==
      ==
  ==
--
