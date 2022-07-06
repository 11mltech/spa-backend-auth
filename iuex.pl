#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::Util 'secure_compare';

get '/spa-auth/login' => sub ($c) {

  # Check for username "Pepe" and password "jose"
  return $c->render(template => 'index')
   if secure_compare $c->req->url->to_abs->userinfo, 'alexa-id:alexa-secret'; 
  # Require authentication
  $c->res->headers->www_authenticate('Basic');
  $c->render(text => 'Authentication required!', status => 401);

};

app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>UI for alexa</title>
    </head>
<body>
    <h1> Formulario de autenticacion</h1>
    <form>
        <label for="username">Usuario</label>
        <input type="text" name="username" id="username">
        <label for="password">Contraseña</label>
        <input type="password" name="password" id="password">
        <input type="submit" value="Enviar">
    </form>
</body>
</html>