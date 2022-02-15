from os import getenv
import datetime
from flask import Flask, json,jsonify,request,abort
from flask_sqlalchemy import SQLAlchemy 
from sqlalchemy.orm import load_only
from marshmallow import Schema,fields
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.orm.exc import NoResultFound, MultipleResultsFound
from sqlalchemy import text

app=Flask(__name__)
app.config.from_envvar('ENV_FILE_LOCATION')
#app.config["SQLALCHEMY_DATABASE_URI"]='postgresql://api_app:api#123@192.168.122.194:5000/api'
#SQLALCHEMY_DATABASE_URI='postgresql://postgres:postgres@localhost:5432/api'
#app.config["SQLALCHEMY_TRACK_MODIFICATIONS"]=False

db=SQLAlchemy(app)

def initialize_db(app):
    db.init_app(app)

class Users(db.Model):
    id=db.Column(db.Integer(),primary_key=True)
    username=db.Column(db.Text(),unique=True)
    birthday=db.Column(db.Text(),nullable=False)

    def __repr__(self):
        return self.birthday

    @classmethod
    def get_by_name(cls,username):
        try:
            return cls.query.filter_by(username=username).options(load_only("username")).one()
        except NoResultFound:
            abort(404)

class UserSchema(Schema):
    username=fields.String()
    birthday=fields.String()

@app.route('/hello/<string:username>',methods=["GET","POST","PUT"])
def hello(username):
    
    if request.method == "GET" :
        user_bithday=Users.get_by_name(username)

        serializer=UserSchema()

        data=serializer.dump(user_bithday)

        today = datetime.date.today()
        date_of_birth = datetime.datetime.strptime(data.get('birthday'), '%Y-%m-%d').date()
        next_birthday = datetime.datetime(today.year,date_of_birth.month,date_of_birth.day).date()
        days = (next_birthday - today).days

        if days>0 :
            return jsonify(message=f"Hello, {username}! Your birthday is in {days} day(s)"),200
        elif days<0:
            next_birthday = datetime.datetime(today.year+1,date_of_birth.month,date_of_birth.day).date()
            days = (next_birthday - today).days
            return jsonify(message=f"Hello, {username}! Your birthday is in {days} day(s)"),200
        else :
            return jsonify(message=f"Hello, {username}! Happy birthday!"),200

    elif request.method == 'PUT':
        data=request.get_json()

        if not request.json or not 'birthday' in request.json:
            abort(401)
        else:
            try:
                datetime_of_birth = datetime.datetime.strptime(data['birthday'], '%Y-%m-%d')
                birthday = datetime_of_birth.date()
            except ValueError as e:
                return jsonify(message=f"{data['birthday']} must be a valid YYYY-MM-DD date."),400

            if datetime.date.today() <= birthday :
                return jsonify(message=f"{data['birthday']} must be a date before the today date."),400

        #try to insert if conflit username update de value
        insert_statement = text("INSERT INTO users (username,birthday) VALUES (:username, :birthday) ON CONFLICT (username) DO UPDATE SET birthday = EXCLUDED.birthday")
        params = [{"username":username, "birthday":data.get('birthday')}]
        
        
        db.session.execute(insert_statement, params)
        db.session.commit()
        
        return ('', 204)

@app.errorhandler(404)
def not_found(error):
    return jsonify({"message":"User not found"}),404

@app.errorhandler(401)
def not_found(error):
    return jsonify({"message":"You need to pass a json context or 'birthday' key is not present on it"}),401

@app.errorhandler(500)
def internal_server(error):
    return jsonify({"message":"There is a problem"}),500

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80)    
