import json
import os

import yaml
from sqlalchemy import create_engine, Column, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import text

BaseSqlAlchemyProjection = declarative_base()


class ExampleProjection(BaseSqlAlchemyProjection):
    __tablename__ = 'example_table'

    id = Column(String, primary_key=True)


def handle(event, context):
    try:
        env = os.environ['env']
        stream = open('secrets/' + env + '.yml').read()
        db_config = yaml.load(stream)
        db_config = db_config['database']
        db_url = 'postgres://' + db_config['user'] + ':' + db_config['password'] + '@' + db_config['host'] + ':5432/' + db_config['name']
        engine = create_engine(db_url)
        sql = """
        SELECT *
        FROM order_approval_queue
        """
        result = engine.connect().execute(text(sql)).fetchall()

        return dict(
            statusCode=200,
            body=json.dumps([dict(element) for element in result])
        )
    except Exception as e:
        return dict(
            statusCode=500,
            body=str(e)
        )
