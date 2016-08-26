#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "mex.h"

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/prettywriter.h" 

using namespace std;
using namespace rapidjson;

#include "common.h"

void BuildStructFromJson(Document& document, mxArray* plhs[]);
mxArray* ConvertValue(Value& value);
mxArray* ConvertObject(Value& object);
size_t GetObjectSize(Value& object);
mxArray* ConvertArray(Value& array);
bool ArrayIsNumeric(Value& array);

#define WARN(_msg)
// #define WARN(_msg)  mexWarnMsgTxt(_msg)

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    char *filename = nullptr;
    Document document;

    try
    {
        ValidateArguments(nlhs, nrhs, prhs, "rjParseJson");     WARN("Validated arguments.\n");
        GetFilenameFromArguments(prhs, filename);               { char msg[1000]; sprintf(msg, "Filename = '%s'.\n", filename); WARN(msg); }
        ReadParseJsonFile(filename, document);                  WARN("Read and parsed JSON file.\n");
        BuildStructFromJson(document, nrhs ? plhs : nullptr);   WARN("Built structure from JSON data.\n");
    }
    catch (char *message)
    {
        MXFREE(filename);
        mexErrMsgIdAndTxt("EMOD:rjParseJson", message);
    }

    MXFREE(filename);
}

void BuildStructFromJson(Document& document, mxArray* plhs[])
{
    mxArray* root = ConvertValue((Value&)document);

    plhs[0] = root;
}

mxArray* ConvertValue(Value& value)
{
    mxArray* matValue = nullptr;

    if (value.IsObject())
    {
        WARN("IsObject");
        matValue = ConvertObject(value);
    }
    else if (value.IsArray())
    {
        WARN("IsArray");
        matValue = ConvertArray(value);
    }
    else if (value.IsNumber())
    {
        WARN("IsNumber");
        matValue = mxCreateDoubleScalar(value.GetDouble());
    }
    else if (value.IsString())
    {
        WARN("IsString");
        matValue = mxCreateString(value.GetString());
    }
    else if (value.IsBool())
    {
        WARN("IsBool");
        matValue = mxCreateLogicalScalar((mxLogical)value.GetBool());
    }
    else if (value.IsNull())
    {
        WARN("IsNull");
        matValue = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    return matValue;
}

mxArray* ConvertObject(Value& object)
{
    mxArray* matObject = nullptr;

    size_t cMembers = GetObjectSize(object);
    char **memberNames = (char**)mxMalloc(cMembers * sizeof(char*));

    char** pName = memberNames;
    for (Value::ConstMemberIterator iterator = object.MemberBegin(); iterator != object.MemberEnd(); iterator++)
    {
        const char *memberName = iterator->name.GetString();
        size_t nameLength = strlen(memberName);

        *pName = (char*)mxMalloc(nameLength + 1);
        strcpy(*pName, memberName);

        for (char *pChar = *pName; *pChar != '\0'; pChar++)
        {
            if (!isalpha(*pChar) && !isdigit(*pChar))
            {
                *pChar = '_';
            }
        }
        pName++;
    }

    matObject = mxCreateStructMatrix(1, 1, (int)cMembers, (const char**)memberNames);

    int iMember = 0;
    for (Value::ConstMemberIterator iterator = object.MemberBegin(); iterator != object.MemberEnd(); iterator++, iMember++)
    {
        WARN(memberNames[iMember]);
        mxSetField(matObject, 0, memberNames[iMember], ConvertValue(object[iterator->name.GetString()]));
    }

    for (int iName = 0; iName < (int)cMembers; iName++)
    {
        mxFree(memberNames[iName]);
    }
    mxFree(memberNames);

    return matObject;
}

size_t GetObjectSize(Value& object)
{
    size_t size = 0;

    if (object.IsObject())
    {
        for (Value::ConstMemberIterator iterator = object.MemberBegin(); iterator != object.MemberEnd(); iterator++)
        {
            size++;
        }
    }

    return size;
}

mxArray* ConvertArray(Value& array)
{
    mxArray* matArray = nullptr;

    if (array.Size() > 0)
    {
        if (ArrayIsNumeric(array))
        {
            matArray = mxCreateDoubleMatrix(array.Size(), 1, mxREAL);
            double* arrayData = mxGetPr(matArray);
            for (Value::ConstValueIterator iterator = array.Begin(); iterator != array.End(); iterator++)
            {
                *arrayData++ = iterator->GetDouble();
            }
        }
        else
        {
            matArray = mxCreateCellMatrix(array.Size(), 1);
            for (SizeType iCell = 0; iCell < array.Size(); iCell++)
            {
                mxSetCell(matArray, (int)iCell, ConvertValue(array[iCell]));
            }

        }
    }
    else
    {
        matArray = mxCreateDoubleMatrix(0, 0, mxREAL);
    }

    return matArray;
}

bool ArrayIsNumeric(Value& array)
{
    bool isNumeric = (array.Size() > 0);

    for (Value::ConstValueIterator iterator = array.Begin(); iterator != array.End(); iterator++)
    {
        if (!iterator->IsNumber())
        {
            isNumeric = false;
            break;
        }
    }

    return isNumeric;
}