<?php

function fatal() {
	if (func_num_args()) {
		$args = func_get_args();
	} elseif (($error = error_get_last())) {
		$args = ["%s", $error["message"]];
	}
	
	if (!empty($args)) {
		if (count($args) === 1 && is_numeric($args[0])) {
			array_unshift($args, "Got signal %d");
		}
		trigger_error(call_user_func_array("sprintf", $args), E_USER_ERROR);
	}
	
	exit;
}

function mkfifo($path) {
	if (!isfifo($path, $stat)) {
		$stat and unlink($path);
		if (!posix_mkfifo($path, 0660)) {
			return false;
		}
	}
	return fopen($path, "r+");
}

function isfifo($path, &$stat = null) {
	return ($stat = @stat($path)) && ($stat["mode"] & POSIX_S_IFIFO);
}

class Client
{
	protected $session;
	protected $channel;
	protected $keyword;
	protected $joined;
	protected $queue = array();
	
	function __construct($url, callable $onJoin) {
		if (!$url = parse_url($url)) {
			fatal("could not parse url: '%s'", $url);
		}
		
		$this->session = $session = new irc\client\Session(
			$url["user"],
			$url["user"],
			$url["user"]
		);
		
		@list($this->channel, $this->keyword) = 
			explode(" ", $url["fragment"]);
		
		$session->onConnect = $session->onPart = function($origin, array $args) {
			$this->joined = false;
			$this->session->doJoin("#".$this->channel, $this->keyword);
		};
		$session->onJoin = function($origin, array $args) use ($onJoin) {
			$this->joined = true;
			$onJoin($this, $origin, $args);
		};
		$session->doConnect(false, $url["host"], @$url["port"]?:6667, @$url["pass"]);
	}
	
	function send($message = null) {
		if (isset($message)) {
			$this->queue[] = $message;
		}
		
		if ($this->joined) {
			while ($this->queue) {
				$this->session->doMsg("#".$this->channel, array_shift($this->queue));
			}
		}
	}
	
	function getSession() {
		return $this->session;
	}
}

if (!extension_loaded("ircclient")) {
	fatal("ext/ircclient not loaded");
}

# vim: noet
