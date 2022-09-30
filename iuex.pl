#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use Mojo::Util 'secure_compare';

my @local_spas = ({name => 'DanTube', code => 1234}, {name => 'PabloSpa', code => 0});

get '/spa-auth/login' => sub ($c) {

  # Check for username "Pepe" and password "jose"
  $c->log->debug("req: " . $c->dumper($c->req));
  $c->log->debug("headers: " . $c->dumper($c->req->headers->to_hash));
  $c->stash(remote_ip => $c->tx->remote_address);
  return $c->render(template => 'index')
   if secure_compare $c->req->url->to_abs->userinfo // '', 'alexa-id:alexa-secret'; 
  # Require authentication
  $c->res->headers->www_authenticate('Basic');
  $c->render(text => 'Authentication required!', status => 401);

};

post '/spa-auth/user-auth' => sub ($c) {
  $c->log->debug("params: " . $c->dumper($c->req->params));
  if ($c->param('username') ne 'pepe' || $c->param('password') ne 'jose') {
   return $c->render(status => 404, text => 'Forbidden');
  };
  my $url = Mojo::URL->new($c->param('redirect_uri'));
  $url->query(state => $c->param('state'), code => '12345678');
  $c->redirect_to($url);
} => 'uauth';

post '/spa-auth/token' => sub ($c) {
  $c->log->debug("params for token: " . $c->dumper($c->req));
  if ($c->param('code') ne '12345678') {
    return $c->render(status => 404, text => 'Forbidden');
  }
  $c->render(json => {
	access_token => 'este-es-nuestro.access.token',
	token_type => 'bearer',
	expires_in => 3600 * 24,
	refresh_token => 'el-token.de.refresco'
	  });
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
    <p> Tu IP es: <%= $c->stash('remote_ip') // 'unknown' %> <p>
    %= form_for $c->url_for('uauth')->to_abs => (method => 'POST') => begin
        %= select_field country => [c(EU => [[Germany => 'de'], 'en'], id => 'eu')]
        <input type="submit" value="Enviar">
        %= hidden_field client_id => $c->param('client_id');
        %= hidden_field redirect_uri => $c->param('redirect_uri');
        %= hidden_field response_type => $c->param('response_type');
        %= hidden_field scope => $c->param('scope');
        %= hidden_field state => $c->param('state'); 
	%= hidden_field ip => $c->tx->remote_address;
    % end
</body>
</html>
