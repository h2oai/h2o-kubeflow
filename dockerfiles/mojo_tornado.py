from datetime import date
import tornado.escape
import tornado.ioloop
import tornado.web
import requests
import json


class welcomePage(tornado.web.RequestHandler):
    def get(self):
        response = {'welcomepage': "Hello, this is the Driverless AI Docker Mojo Deployment Prototype"}
        self.write(response)


class versionHandler(tornado.web.RequestHandler):
    def get(self):
        response = {'version': '0.0.1',
                    'last_build':  date.today().isoformat(),
                    'description': 'prototype deployment for Driverless AI mojos in Docker'}
        self.write(response)


class basePostHandler(tornado.web.RequestHandler):
    def post(self):
        data = self.get_argument('body', 'No Data Received')
        response = "Hello! You Have Encountered The Test Page! You Input Was: {}".format(data)
        self.write(response)

    get = post


class restGetModelFeaturesHandler(tornado.web.RequestHandler):
    def post(self):
        model_name = self.get_argument('name', "No Data Received")
        data = {"name": model_name}
        url = 'http://localhost:8080/modelfeatures'
        response = requests.post(url, params=data)
        self.write(response.content)

    get = post


class restScoreRow(tornado.web.RequestHandler):
    def post(self):
        model_name = self.get_argument('name', "No Model Name")
        row_string = self.get_argument('row', "No Data Recieved")
        data = {'name': model_name, 'row': row_string}
        url = 'http://localhost:8080/model'
        response = requests.post(url, params=data)
        result = json.loads(response.content.decode('utf-8'))
        result = result['result'].replace("=", "").split()
        self.write({'{}'.format(result[0]): result[1],
                    '{}'.format(result[2]): result[3]})

    get = post


class restScoreBatch(tornado.web.RequestHandler):
    def post(self):
        all_preds = dict()
        batch_file = self.request.files['file'][0]
        model_name = self.get_argument('name', "No Model Name")
        header = self.get_argument('header', 'true')
        lines = batch_file['body'].decode('utf-8').split()
        if header == 'true':
            lines = lines[1:]

        for i, line in enumerate(lines):
            line = line.replace('"', "").replace("'", "")
            data = {'name': model_name, 'row': line}
            url = 'http://localhost:8080/model'
            response = requests.post(url, params=data)
            result = json.loads(response.content.decode('utf-8'))
            result = result['result'].replace("=", "").split(" ")
            all_preds['{}'.format(i)] = dict({'{}'.format(result[0]): result[1],
                                              '{}'.format(result[2]): result[3]})
        self.write(all_preds)


application = tornado.web.Application([
    (r"/", welcomePage),
    (r"/version", versionHandler),
    (r"/postsomething", basePostHandler),
    (r"/modelfeatures", restGetModelFeaturesHandler),
    (r"/scorerow", restScoreRow),
    (r"/scorebatch", restScoreBatch)
])

if __name__ == "__main__":
    application.listen(5555)
    tornado.ioloop.IOLoop.instance().start()
