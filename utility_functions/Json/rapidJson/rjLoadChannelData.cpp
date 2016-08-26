#include <stdio.h>
#include <string.h>
#include "mex.h"

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/prettywriter.h" 

using namespace std;
using namespace rapidjson;

#include "common.h"

void BuildStructFromJson(Document& document, mxArray** plhs);
void VerifyVersionTwoOrThree(Document& document);
int GetChartVersion(Document& document);
void CheckForMember(Value& value, const char* memberName);
void CheckForArray(Value& value, const char* memberName, int nElements = 0);
void CheckForObject(Value& value, const char* memberName, int nMembers = 0);
int GetMemberCount(Value& object);
mxArray* BuildVersionOneStructure(Document& document);
mxArray* BuildVersionOneHeader(const char* reportVersion, int nTimesteps, int nChannels);
mxArray* BuildVersionTwoOrThreeStructure(Document& document);
mxArray* BuildVersionTwoOrThreeHeader(Value& jsonHeader, int nTimesteps, int nChannels);

#define WARN(_msg)
// #define WARN(_msg)  mexWarnMsgTxt(_msg)

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    char *filename = nullptr;
    Document document;

    try
    {
        ValidateArguments(nlhs, nrhs, prhs, "rjLoadChannelData");   WARN("Validated arguments.\n");
        GetFilenameFromArguments(prhs, filename);                   { char msg[1000]; sprintf(msg, "Filename = '%s'.\n", filename); WARN(msg); }
        ReadParseJsonFile(filename, document);                      WARN("Read and parsed JSON file.\n");
        BuildStructFromJson(document, nrhs ? plhs : nullptr);       WARN("Built structure from JSON data.\n");
    }
    catch (char *message)
    {
        MXFREE(filename);
        mexErrMsgIdAndTxt("EMOD:rjLoadChannelData", message);
    }

    MXFREE(filename);
}

void BuildStructFromJson(Document& document, mxArray** plhs)
{
    int chartVersion = GetChartVersion(document);
    mxArray* matStructure = nullptr;

    switch (chartVersion)
    {
        case 1:
            matStructure = BuildVersionOneStructure(document);
            break;

        case 2:
        case 3:
            matStructure = BuildVersionTwoOrThreeStructure(document);
            break;

        default:
            {
                static char msg[1000];
                sprintf(msg, "Unknown chart version %d.", chartVersion);
                throw msg;
            }
    }

    if (plhs)
    {
        plhs[0] = matStructure;
    }
}

void VerifyVersionTwoOrThree(Document& document)
{
    /*
    ** Version 2 Expected structure:
    ** {
    **     "Header" : {
    **         "DateTime"       : string
    **         "DTK_Version"    : string
    **         "Report_Version" : string
    **         "Timesteps"      : number
    **         "Channels"       : number
    **     }
    **     "ChannelTitles" : [ title0, title1, ..., titleN ],   // optional
    **     "ChannelUnits"  : [ units0, units1, ..., unitsN ],   // optional
    **     "ChannelData"   : [ [ ... ], [ ... ], .... [ ... ] ]
    ** }
    **
    ** Version 3 Expected structure:
    ** {
    **     "Header" : {
    **         "DateTime"       : string
    **         "DTK_Version"    : string
    **         "Report_Version" : string
    **         "Timesteps"      : number
    **         "Channels"       : number
    **     }
    **     "Channels" : {
    **         "channel name" : {
    **             "Units" : string
    **             "Data" : [ ... ]
    **         }
    **     }
    ** }
    */
    CheckForMember(document, "Header");
    Value& header = document["Header"];
    CheckForMember(header, "DateTime");
    CheckForMember(header, "DTK_Version");
    CheckForMember(header, "Report_Version");
    CheckForMember(header, "Timesteps");
    CheckForMember(header, "Channels");
    int channelCount = header["Channels"].GetInt();
    CheckForObject(document, "Channels", channelCount);

    // TODO: verify all titles are strings
    // TODO: verify all units are strings
    // TODO: verify all channels contain numeric 'Data' array member of same length
}

int GetChartVersion(Document& document)
{
    int chartVersion = 1;

    if (document.HasMember("Header") && document["Header"].IsObject() && document["Header"].HasMember("Report_Version"))
    {
        chartVersion = atoi(document["Header"]["Report_Version"].GetString());
    }

    {
        char msg[1000];
        sprintf(msg, "Detected chart version: %d.\n", chartVersion);
        WARN(msg);
    }

    switch (chartVersion)
    {
        case 1:
            {
                /*
                ** Expected structure:
                ** {
                **     "ChannelTitles" : [ title0, title1, ..., titleN ],
                **     "ChannelUnits"  : [ units0, units1, ..., unitsN ],
                **     "ChannelData"   : [ [ sample0, sample1, ..., sampleM ], ... ]
                ** }
                */
                CheckForArray(document, "ChannelTitles");
                int nTitles   = document["ChannelTitles"].Size();
                CheckForArray(document, "ChannelUnits", nTitles);
                CheckForArray(document, "ChannelData", nTitles);

                int nUnits    = document["ChannelUnits"].Size();
                int nChannels = document["ChannelData"].Size();

                // TODO: verify all titles are strings
                // TODO: verify all units are strings
                // TODO: verify all channels are numeric and same length
            }
            break;

        case 2:
        case 3:
            {
                VerifyVersionTwoOrThree(document);
            }
            break;

        default:
            // Nothing to do here, let BuildStructFromJson() handle the issue.
            break;
    }

    return chartVersion;
}

void CheckForMember(Value& value, const char* memberName)
{
    if (!value.HasMember(memberName))
    {
        static char msg[1000];
        sprintf(msg, "Missing member '%s'.", memberName);
        throw msg;
    }
}

void CheckForArray(Value& value, const char* memberName, int nElements)
{
    CheckForMember(value, memberName);
    if (!value[memberName].IsArray())
    {
        static char msg[1000];
        sprintf(msg, "Member '%s' isn't an array.", memberName);
        throw msg;
    }

    if ((nElements > 0) && (value[memberName].Size() != nElements))
    {
        static char msg[1000];
        sprintf(msg, "Array '%s' doesn't have the correct number of elements, %d expected, %d found.", memberName, nElements, value[memberName].Size());
        throw msg;
    }
}

void CheckForObject(Value& value, const char* memberName, int nMembers)
{
    CheckForMember(value, memberName);
    if (!value[memberName].IsObject())
    {
        static char msg[1000];
        sprintf(msg, "Member '%s' isn't an object.", memberName);
        throw msg;
    }

    int memberCount = GetMemberCount(value[memberName]);
    if ((nMembers != 0) && (memberCount != nMembers))
    {
        static char msg[1000];
        sprintf(msg, "Object '%s' doesn't have the correct number of elements, %d expected, %d found.", memberName, nMembers, memberCount);
        throw msg;
    }
}

int GetMemberCount(Value& object)
{
    int elementCount = 0;

    if (!object.IsObject())
    {
        throw "GetMemberCount() called on non-object value.";
    }

    for (Value::ConstMemberIterator iterator = object.MemberBegin(); iterator != object.MemberEnd(); iterator++)
    {
        elementCount++;
    }

    return elementCount;
}

mxArray* BuildVersionOneStructure(Document& document)
{
    WARN("Building struct for version 1 inset chart JSON.\n");

    int nChannels = document["ChannelTitles"].Size();
    int channelDataSize = document["ChannelData"].Size();

    if (nChannels != channelDataSize)
    {
        static char msg[1000];
        sprintf(msg, "Number of channel titles (%d) doesn't match number of data channels (%d).", nChannels, channelDataSize);
        throw msg;
    }

    int nSteps = document["ChannelData"][SizeType(0)].Size();

    mxArray* matHeader = nullptr;
    mxArray* matTitles = nullptr;
    mxArray* matUnits  = nullptr;
    mxArray* matData   = nullptr;

    const char *structureFields[] = { "Header", "ChannelTitles", "ChannelUnits", "ChannelData" };

    mxArray* matStructure = mxCreateStructMatrix(1, 1, 4, structureFields);
    mxSetField(matStructure, 0, "Header", matHeader = BuildVersionOneHeader("1", nSteps, nChannels));
    mxSetField(matStructure, 0, "ChannelTitles", matTitles = mxCreateCellMatrix(nChannels, 1));
    mxSetField(matStructure, 0, "ChannelUnits", matUnits = mxCreateCellMatrix(nChannels, 1));
    mxSetField(matStructure, 0, "ChannelData", matData = mxCreateDoubleMatrix(nChannels, nSteps, mxREAL));

    double* matrixData = mxGetPr(matData);
    Value& channelData = document["ChannelData"];

    for (int iChannel = 0; iChannel < nChannels; iChannel++)
    {
        const char* channelTitle = document["ChannelTitles"][iChannel].GetString();
        mxSetCell(matTitles, iChannel, mxCreateString(channelTitle));

        const char* channelUnits = document["ChannelUnits"][iChannel].GetString();
        mxSetCell(matUnits, iChannel, mxCreateString(channelUnits));

        // MATLAB matrices are in column major order
        double* rowData = matrixData + iChannel;
        Value& vector = channelData[iChannel];
        Value::ConstValueIterator iterator = vector.Begin();

        for (int iStep = 0; iStep < nSteps; iStep++, iterator++)
        {
            *rowData = iterator->GetDouble();
            rowData += nChannels;
        }
    }

    return matStructure;
}

mxArray* BuildVersionOneHeader(const char* reportVersion, int nTimesteps, int nChannels)
{
    const char *headerFields[] = { "Report_Version", "Timesteps", "Channels" };
    mxArray* matHeader = mxCreateStructMatrix(1, 1, 3, headerFields);
    mxSetField(matHeader, 0, "Report_Version", mxCreateString(reportVersion));
    mxSetField(matHeader, 0, "Timesteps",      mxCreateDoubleScalar(nTimesteps));
    mxSetField(matHeader, 0, "Channels",       mxCreateDoubleScalar(nChannels));

    return matHeader;
}

mxArray* BuildVersionTwoOrThreeStructure(Document& document)
{
    WARN("Building struct for version 2 inset chart JSON.\n");

    Value& jsonHeader  = document["Header"];
    int nChannels      = GetMemberCount(document["Channels"]);

    int nSteps  = jsonHeader["Timesteps"].GetInt();

    mxArray* matHeader = nullptr;
    mxArray* matTitles = nullptr;
    mxArray* matUnits  = nullptr;
    mxArray* matData   = nullptr;

    const char *structureFields[] = { "Header", "ChannelTitles", "ChannelUnits", "ChannelData" };

    mxArray* matStructure = mxCreateStructMatrix(1, 1, 4, structureFields);
    mxSetField(matStructure, 0, "Header", matHeader = BuildVersionTwoOrThreeHeader(jsonHeader, nSteps, nChannels));
    mxSetField(matStructure, 0, "ChannelTitles", matTitles = mxCreateCellMatrix(nChannels, 1));
    mxSetField(matStructure, 0, "ChannelUnits", matUnits = mxCreateCellMatrix(nChannels, 1));
    mxSetField(matStructure, 0, "ChannelData", matData = mxCreateDoubleMatrix(nChannels, nSteps, mxREAL));

    double* matrixData = mxGetPr(matData);
    Value& channels = document["Channels"];

    Value::ConstMemberIterator iterator = channels.MemberBegin();
    for (int iChannel = 0; iChannel < nChannels; iChannel++, iterator++)
    {
        const char* channelTitle = iterator->name.GetString();
        mxSetCell(matTitles, iChannel, mxCreateString(channelTitle));

        const Value& channel = iterator->value;
        const char* channelUnits = channel["Units"].GetString();
        mxSetCell(matUnits, iChannel, mxCreateString(channelUnits));
    
        // MATLAB matrices are in column major order
        double* rowData = matrixData + iChannel;
        const Value& vector = channel["Data"];
        Value::ConstValueIterator iterator = vector.Begin();

        for (int iStep = 0; iStep < nSteps; iStep++, iterator++)
        {
            *rowData = iterator->GetDouble();
            rowData += nChannels;
        }
    }

    return matStructure;
}

mxArray* BuildVersionTwoOrThreeHeader(Value& jsonHeader, int nTimesteps, int nChannels)
{
    const char *headerFields[] = { "DateTime", "DTK_Version", "Report_Version", "Timesteps", "Channels" };
    mxArray* matHeader = mxCreateStructMatrix(1, 1, 5, headerFields);
    mxSetField(matHeader, 0, "DateTime",       mxCreateString(jsonHeader["DateTime"].GetString()));
    mxSetField(matHeader, 0, "DTK_Version",    mxCreateString(jsonHeader["DTK_Version"].GetString()));
    mxSetField(matHeader, 0, "Report_Version", mxCreateString(jsonHeader["Report_Version"].GetString()));
    mxSetField(matHeader, 0, "Timesteps",      mxCreateDoubleScalar(nTimesteps));
    mxSetField(matHeader, 0, "Channels",       mxCreateDoubleScalar(nChannels));

    return matHeader;
}
