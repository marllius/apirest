#~/test/tests.py

import unittest
import json
import datetime
#from datetime import datetime, timedelta

from app import app

class SignupTest(unittest.TestCase):

    def setUp(self):
        self.app = app.test_client()

    def test_insert(self):
        # Given
        payload = json.dumps({
            "dateOfBirth": "1988-04-12"
        })

        # When
        response = self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=payload)

        # Then
        self.assertEqual(204, response.status_code)

    def test_update(self):
        payload = json.dumps({
            "dateOfBirth": "1988-04-07"
        })

        # When
        response = self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=payload)        

        # Then
        self.assertEqual(None, response.json)
        self.assertEqual(204, response.status_code)

    def test_happy_birthday_message(self):

        today = datetime.date.today()
        last_birthday = datetime.datetime(today.year-1,today.month,today.day).date().strftime("%Y-%m-%d")

        data = {'dateOfBirth': last_birthday}
        last_birthday = json.dumps(data)

        self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=last_birthday)
        
        # When
        response = self.app.get('/hello/John', headers={"Content-Type": "application/json"})

        # Then
        self.assertEqual({'message': 'Hello, John! Happy birthday!'}, response.json)
        self.assertEqual(200, response.status_code)

    def test_days_to_birthday_message(self):

        today = datetime.date.today()
        tomorrow = datetime.datetime(today.year-1,today.month,today.day+1).date().strftime("%Y-%m-%d")

        data = {'dateOfBirth': tomorrow}
        tomorrow_birthday = json.dumps(data)

        self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=tomorrow_birthday)
        
        # When
        response = self.app.get('/hello/John', headers={"Content-Type": "application/json"})

        # Then
        self.assertEqual({'message': 'Hello, John! Your birthday is in 1 day(s)'}, response.json)
        self.assertEqual(200, response.status_code)

    def test_not_valid_date_format_message(self):

        payload = json.dumps({
            "dateOfBirth": "1988-04-0"
        })

        # When
        response = self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=payload)

        # Then
        self.assertEqual({'message': '1988-04-0 must be a valid YYYY-MM-DD date.'}, response.json)
        self.assertEqual(400, response.status_code)

    def test_date_greater_than_today_message(self):

        today = datetime.date.today()
        tomorrow = datetime.datetime(today.year,today.month,today.day+1).date().strftime("%Y-%m-%d")
        data = {'dateOfBirth': tomorrow}
        
        tomorrow_birthday = json.dumps(data)
        
        payload = {'message': data['dateOfBirth']+' must be a date before the today date.'}

        # When
        response = self.app.put('/hello/John', headers={"Content-Type": "application/json"}, data=tomorrow_birthday)

        # Then
        self.assertEqual(payload, response.json)
        self.assertEqual(400, response.status_code)        