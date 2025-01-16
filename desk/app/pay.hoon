/-  *pay
/+  dbug, default-agent, server, schooner
/*  ui  %html  /app/pay/html
::
|%
+$  versioned-state  $%(state-0)
+$  state-0  
  $:  %0
      =ledger
      public=wallet
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
  `this
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
  %-  emil
  :~  %-  alchemy-card
      ['0xda2701e7832da518054d6cc727b28169a36acb2f' %.n]
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
  |=  [=wallet from=?]
  ^-  card
  :*  %pass  /alchemy/[wallet]  %arvo  %i
      %request  (alchemy-request wallet from) 
      *outbound-config:iris
  ==
::
::  Create an HTTP request to Alchemy.
++  alchemy-request
  |=  [=wallet from=?]
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
                  ?:  from
                    ['fromAddress' [%s wallet]]
                  ['toAddress' [%s wallet]]
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
  =/  =wallet  +6:wire
  =/  response  client-response.sign
  ?+    -.response  that
      %finished
    =/  mime  (need full-file.response)
    =/  =json  (need (de:json:html q.data.mime))
    =/  transactions  (dejs-response json)
    =.  ledger  (~(put by ledger) wallet transactions)
    that
  ==
::
++  watch
  |=  =path
  ^+  that
  ?+    path  that
      [%http-response *]
    that
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
    ?~  body.request.inbound-request  !!
    =/  json  (de:json:html q.u.body.request.inbound-request)
    that
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
        [%apps %pay %address @ ~]
      =/  address  '0x32B3A783f2dF80a01B1a8D3033c2Cab32b477D2b'
      [200 ~ [%json [%o (malt ['address' [%s address]]~)]]]
    ==
  ==
::
++  enjs-state
  =,  enjs:format
  ^-  json
  %-  frond
  :-  %ledger
  :-  %a
  %+  turn
    ~(tap by ledger)
  |=  [=wallet transactions=(list transaction)]
  %-  pairs
  :~  [%address [%s wallet]]
      :-  %transactions  :: %ledger?
      :-  %a
      %+  turn
        transactions
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
