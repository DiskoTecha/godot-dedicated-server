extends Node

var X509_cert_filename = "X509_Certificate.crt"
var X509_key_filename = "X509_Key.key"
@onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
@onready var X509_key_path = "user://Certificate/" + X509_key_filename

var CN = "testserver"
var O = "DylanWadsworth"
var C = "US"
var not_before = "20241207000000"
var not_after = "20251207000000"

# Called when the node enters the scene tree for the first time.
func _ready():
	if DirAccess.dir_exists_absolute("user://Certificate"):
		pass
	else:
		DirAccess.make_dir_absolute("user://Certificate")
	createX509Certificate()
	print("Certificate Created")


func createX509Certificate():
	var CNOC = "CN=" + CN + ",O=" + O + "C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_certificate = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	var error = X509_certificate.save(X509_cert_path)
	if error:
		print("Could not save certificate")
		return error
	error = crypto_key.save(X509_key_path)
	if error:
		print("Could not save crypto key")
		return error
