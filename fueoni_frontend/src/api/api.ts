/* tslint:disable */
/* eslint-disable */
/**
 * FueOni_ver2
 * No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)
 *
 * The version of the OpenAPI document: 0.1.0
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */


import type { Configuration } from './configuration';
import type { AxiosPromise, AxiosInstance, AxiosRequestConfig } from 'axios';
import globalAxios from 'axios';
// Some imports not used depending on template conditions
// @ts-ignore
import { DUMMY_BASE_URL, assertParamExists, setApiKeyToObject, setBasicAuthToObject, setBearerAuthToObject, setOAuthToObject, setSearchParams, serializeDataIfNeeded, toPathString, createRequestFunction } from './common';
import type { RequestArgs } from './base';
// @ts-ignore
import { BASE_PATH, COLLECTION_FORMATS, BaseAPI, RequiredError, operationServerMap } from './base';

/**
 * 
 * @export
 * @interface AllMissionsResponse
 */
export interface AllMissionsResponse {
    /**
     * 
     * @type {{ [key: string]: Mission; }}
     * @memberof AllMissionsResponse
     */
    'missions': { [key: string]: Mission; };
}
/**
 * 
 * @export
 * @enum {string}
 */

export const Difficulty = {
    Easy: 'easy',
    Normal: 'normal',
    Hard: 'hard'
} as const;

export type Difficulty = typeof Difficulty[keyof typeof Difficulty];


/**
 * 
 * @export
 * @interface HTTPValidationError
 */
export interface HTTPValidationError {
    /**
     * 
     * @type {Array<ValidationError>}
     * @memberof HTTPValidationError
     */
    'detail'?: Array<ValidationError>;
}
/**
 * 
 * @export
 * @interface Mission
 */
export interface Mission {
    /**
     * 
     * @type {string}
     * @memberof Mission
     */
    'title': string;
    /**
     * 
     * @type {string}
     * @memberof Mission
     */
    'description': string;
    /**
     * 
     * @type {string}
     * @memberof Mission
     */
    'answer': string;
    /**
     * 
     * @type {string}
     * @memberof Mission
     */
    'type': string;
    /**
     * 
     * @type {Difficulty}
     * @memberof Mission
     */
    'difficulty': Difficulty;
    /**
     * 
     * @type {number}
     * @memberof Mission
     */
    'time_limit': number;
}


/**
 * 
 * @export
 * @interface MissionsResponse
 */
export interface MissionsResponse {
    /**
     * 
     * @type {{ [key: string]: Mission; }}
     * @memberof MissionsResponse
     */
    'missions': { [key: string]: Mission; };
    /**
     * 
     * @type {PagingInfo}
     * @memberof MissionsResponse
     */
    'paging_info': PagingInfo;
}
/**
 * 
 * @export
 * @interface PagingInfo
 */
export interface PagingInfo {
    /**
     * Current page number
     * @type {number}
     * @memberof PagingInfo
     */
    'current_page': number;
    /**
     * Total number of pages
     * @type {number}
     * @memberof PagingInfo
     */
    'total_pages': number;
}
/**
 * 
 * @export
 * @interface ValidationError
 */
export interface ValidationError {
    /**
     * 
     * @type {Array<ValidationErrorLocInner>}
     * @memberof ValidationError
     */
    'loc': Array<ValidationErrorLocInner>;
    /**
     * 
     * @type {string}
     * @memberof ValidationError
     */
    'msg': string;
    /**
     * 
     * @type {string}
     * @memberof ValidationError
     */
    'type': string;
}
/**
 * 
 * @export
 * @interface ValidationErrorLocInner
 */
export interface ValidationErrorLocInner {
}

/**
 * MissionsApi - axios parameter creator
 * @export
 */
export const MissionsApiAxiosParamCreator = function (configuration?: Configuration) {
    return {
        /**
         * 
         * @summary Add Mission
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        addMissionApiV1MissionsAddMissionPost: async (mission: Mission, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            // verify required parameter 'mission' is not null or undefined
            assertParamExists('addMissionApiV1MissionsAddMissionPost', 'mission', mission)
            const localVarPath = `/api/v1/missions/add_mission`;
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'POST', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            localVarHeaderParameter['Content-Type'] = 'application/json';

            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};
            localVarRequestOptions.data = serializeDataIfNeeded(mission, localVarRequestOptions, configuration)

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
        /**
         * 
         * @summary Delete Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        deleteMissionApiV1MissionsDeleteMissionMissionIdDelete: async (missionId: string, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            // verify required parameter 'missionId' is not null or undefined
            assertParamExists('deleteMissionApiV1MissionsDeleteMissionMissionIdDelete', 'missionId', missionId)
            const localVarPath = `/api/v1/missions/delete_mission/{mission_id}`
                .replace(`{${"mission_id"}}`, encodeURIComponent(String(missionId)));
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'DELETE', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
        /**
         * 
         * @summary Get All Missions
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getAllMissionsApiV1MissionsAllMissionsGet: async (options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            const localVarPath = `/api/v1/missions/all_missions`;
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'GET', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
        /**
         * 
         * @summary Get Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getMissionApiV1MissionsMissionMissionIdGet: async (missionId: string, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            // verify required parameter 'missionId' is not null or undefined
            assertParamExists('getMissionApiV1MissionsMissionMissionIdGet', 'missionId', missionId)
            const localVarPath = `/api/v1/missions/mission/{mission_id}`
                .replace(`{${"mission_id"}}`, encodeURIComponent(String(missionId)));
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'GET', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
        /**
         * 
         * @summary Get Missions
         * @param {number} [limit] 
         * @param {number} [startAfter] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getMissionsApiV1MissionsMissionsGet: async (limit?: number, startAfter?: number, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            const localVarPath = `/api/v1/missions/missions`;
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'GET', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;

            if (limit !== undefined) {
                localVarQueryParameter['limit'] = limit;
            }

            if (startAfter !== undefined) {
                localVarQueryParameter['start_after'] = startAfter;
            }


    
            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
        /**
         * 
         * @summary Update Mission
         * @param {string} missionId 
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        updateMissionApiV1MissionsUpdateMissionMissionIdPut: async (missionId: string, mission: Mission, options: AxiosRequestConfig = {}): Promise<RequestArgs> => {
            // verify required parameter 'missionId' is not null or undefined
            assertParamExists('updateMissionApiV1MissionsUpdateMissionMissionIdPut', 'missionId', missionId)
            // verify required parameter 'mission' is not null or undefined
            assertParamExists('updateMissionApiV1MissionsUpdateMissionMissionIdPut', 'mission', mission)
            const localVarPath = `/api/v1/missions/update_mission/{mission_id}`
                .replace(`{${"mission_id"}}`, encodeURIComponent(String(missionId)));
            // use dummy base URL string because the URL constructor only accepts absolute URLs.
            const localVarUrlObj = new URL(localVarPath, DUMMY_BASE_URL);
            let baseOptions;
            if (configuration) {
                baseOptions = configuration.baseOptions;
            }

            const localVarRequestOptions = { method: 'PUT', ...baseOptions, ...options};
            const localVarHeaderParameter = {} as any;
            const localVarQueryParameter = {} as any;


    
            localVarHeaderParameter['Content-Type'] = 'application/json';

            setSearchParams(localVarUrlObj, localVarQueryParameter);
            let headersFromBaseOptions = baseOptions && baseOptions.headers ? baseOptions.headers : {};
            localVarRequestOptions.headers = {...localVarHeaderParameter, ...headersFromBaseOptions, ...options.headers};
            localVarRequestOptions.data = serializeDataIfNeeded(mission, localVarRequestOptions, configuration)

            return {
                url: toPathString(localVarUrlObj),
                options: localVarRequestOptions,
            };
        },
    }
};

/**
 * MissionsApi - functional programming interface
 * @export
 */
export const MissionsApiFp = function(configuration?: Configuration) {
    const localVarAxiosParamCreator = MissionsApiAxiosParamCreator(configuration)
    return {
        /**
         * 
         * @summary Add Mission
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async addMissionApiV1MissionsAddMissionPost(mission: Mission, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<void>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.addMissionApiV1MissionsAddMissionPost(mission, options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.addMissionApiV1MissionsAddMissionPost']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
        /**
         * 
         * @summary Delete Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId: string, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<void>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId, options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.deleteMissionApiV1MissionsDeleteMissionMissionIdDelete']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
        /**
         * 
         * @summary Get All Missions
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async getAllMissionsApiV1MissionsAllMissionsGet(options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<AllMissionsResponse>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.getAllMissionsApiV1MissionsAllMissionsGet(options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.getAllMissionsApiV1MissionsAllMissionsGet']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
        /**
         * 
         * @summary Get Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async getMissionApiV1MissionsMissionMissionIdGet(missionId: string, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<Mission>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.getMissionApiV1MissionsMissionMissionIdGet(missionId, options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.getMissionApiV1MissionsMissionMissionIdGet']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
        /**
         * 
         * @summary Get Missions
         * @param {number} [limit] 
         * @param {number} [startAfter] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async getMissionsApiV1MissionsMissionsGet(limit?: number, startAfter?: number, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<MissionsResponse>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.getMissionsApiV1MissionsMissionsGet(limit, startAfter, options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.getMissionsApiV1MissionsMissionsGet']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
        /**
         * 
         * @summary Update Mission
         * @param {string} missionId 
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        async updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId: string, mission: Mission, options?: AxiosRequestConfig): Promise<(axios?: AxiosInstance, basePath?: string) => AxiosPromise<void>> {
            const localVarAxiosArgs = await localVarAxiosParamCreator.updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId, mission, options);
            const index = configuration?.serverIndex ?? 0;
            const operationBasePath = operationServerMap['MissionsApi.updateMissionApiV1MissionsUpdateMissionMissionIdPut']?.[index]?.url;
            return (axios, basePath) => createRequestFunction(localVarAxiosArgs, globalAxios, BASE_PATH, configuration)(axios, operationBasePath || basePath);
        },
    }
};

/**
 * MissionsApi - factory interface
 * @export
 */
export const MissionsApiFactory = function (configuration?: Configuration, basePath?: string, axios?: AxiosInstance) {
    const localVarFp = MissionsApiFp(configuration)
    return {
        /**
         * 
         * @summary Add Mission
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        addMissionApiV1MissionsAddMissionPost(mission: Mission, options?: any): AxiosPromise<void> {
            return localVarFp.addMissionApiV1MissionsAddMissionPost(mission, options).then((request) => request(axios, basePath));
        },
        /**
         * 
         * @summary Delete Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId: string, options?: any): AxiosPromise<void> {
            return localVarFp.deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId, options).then((request) => request(axios, basePath));
        },
        /**
         * 
         * @summary Get All Missions
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getAllMissionsApiV1MissionsAllMissionsGet(options?: any): AxiosPromise<AllMissionsResponse> {
            return localVarFp.getAllMissionsApiV1MissionsAllMissionsGet(options).then((request) => request(axios, basePath));
        },
        /**
         * 
         * @summary Get Mission
         * @param {string} missionId 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getMissionApiV1MissionsMissionMissionIdGet(missionId: string, options?: any): AxiosPromise<Mission> {
            return localVarFp.getMissionApiV1MissionsMissionMissionIdGet(missionId, options).then((request) => request(axios, basePath));
        },
        /**
         * 
         * @summary Get Missions
         * @param {number} [limit] 
         * @param {number} [startAfter] 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        getMissionsApiV1MissionsMissionsGet(limit?: number, startAfter?: number, options?: any): AxiosPromise<MissionsResponse> {
            return localVarFp.getMissionsApiV1MissionsMissionsGet(limit, startAfter, options).then((request) => request(axios, basePath));
        },
        /**
         * 
         * @summary Update Mission
         * @param {string} missionId 
         * @param {Mission} mission 
         * @param {*} [options] Override http request option.
         * @throws {RequiredError}
         */
        updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId: string, mission: Mission, options?: any): AxiosPromise<void> {
            return localVarFp.updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId, mission, options).then((request) => request(axios, basePath));
        },
    };
};

/**
 * MissionsApi - object-oriented interface
 * @export
 * @class MissionsApi
 * @extends {BaseAPI}
 */
export class MissionsApi extends BaseAPI {
    /**
     * 
     * @summary Add Mission
     * @param {Mission} mission 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public addMissionApiV1MissionsAddMissionPost(mission: Mission, options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).addMissionApiV1MissionsAddMissionPost(mission, options).then((request) => request(this.axios, this.basePath));
    }

    /**
     * 
     * @summary Delete Mission
     * @param {string} missionId 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId: string, options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).deleteMissionApiV1MissionsDeleteMissionMissionIdDelete(missionId, options).then((request) => request(this.axios, this.basePath));
    }

    /**
     * 
     * @summary Get All Missions
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public getAllMissionsApiV1MissionsAllMissionsGet(options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).getAllMissionsApiV1MissionsAllMissionsGet(options).then((request) => request(this.axios, this.basePath));
    }

    /**
     * 
     * @summary Get Mission
     * @param {string} missionId 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public getMissionApiV1MissionsMissionMissionIdGet(missionId: string, options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).getMissionApiV1MissionsMissionMissionIdGet(missionId, options).then((request) => request(this.axios, this.basePath));
    }

    /**
     * 
     * @summary Get Missions
     * @param {number} [limit] 
     * @param {number} [startAfter] 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public getMissionsApiV1MissionsMissionsGet(limit?: number, startAfter?: number, options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).getMissionsApiV1MissionsMissionsGet(limit, startAfter, options).then((request) => request(this.axios, this.basePath));
    }

    /**
     * 
     * @summary Update Mission
     * @param {string} missionId 
     * @param {Mission} mission 
     * @param {*} [options] Override http request option.
     * @throws {RequiredError}
     * @memberof MissionsApi
     */
    public updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId: string, mission: Mission, options?: AxiosRequestConfig) {
        return MissionsApiFp(this.configuration).updateMissionApiV1MissionsUpdateMissionMissionIdPut(missionId, mission, options).then((request) => request(this.axios, this.basePath));
    }
}


