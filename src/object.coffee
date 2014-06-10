unless Object.getPropertyDescriptor?
  if Object.getPrototypeOf? and Object.getOwnPropertyDescriptor?
    Object.getPropertyDescriptor = (o, name) ->
      proto = o
      descriptor = undefined
      proto = Object.getPrototypeOf?(proto) or proto.__proto__ while proto and not (descriptor = Object.getOwnPropertyDescriptor(proto, name))
      descriptor
  else
    Object.getPropertyDescriptor = -> undefined
