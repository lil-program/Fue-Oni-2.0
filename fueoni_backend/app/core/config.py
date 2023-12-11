import enum
from typing import Optional

from pydantic_settings import BaseSettings


class AppEnvironment(str, enum.Enum):
    DEVELOP = "development"
    PRODUCTION = "production"


class Settings(BaseSettings):
    ENVIRONMENT: AppEnvironment

    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "FueOni_ver2"
    
    FIREBASE_PROJECT_JSON: str
    DATABASE_URL: str

    PRODUCT_SEVER_DOMAIN: Optional[str] = None

    def is_production(self):
        return self.ENVIRONMENT == AppEnvironment.PRODUCTION

    def is_development(self):
        return self.ENVIRONMENT == AppEnvironment.DEVELOP


settings = Settings()
