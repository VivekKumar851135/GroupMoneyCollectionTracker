class Loginrequest {
   String? email;
   String? password;
Loginrequest({this.email, this.password});
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
  
}