backends = [
  '127.0.0.1:80'
]

uri = '/mruby-hello'
backends[rand(backends.length)] + uri
