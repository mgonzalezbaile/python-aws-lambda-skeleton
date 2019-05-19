import os
from uuid import uuid4

import yaml
from assertpy import assert_that
from sqlalchemy import create_engine, Column, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

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
        session = sessionmaker(bind=engine, autocommit=True)
        session = session()
        BaseSqlAlchemyProjection.metadata.create_all(engine)
        session.begin()
        record_id = str(uuid4())
        projection = ExampleProjection(id=record_id)
        session.add(projection)
        session.commit()

        assert_that(True).is_equal_to(True)

        return dict(
            statusCode=200,
            body='Record inserted: ' + record_id
        )
    except Exception as e:
        return dict(
            statusCode=500,
            body=str(e)
        )
