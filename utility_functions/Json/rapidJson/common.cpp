#include <stdio.h>
#include "mex.h"

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/prettywriter.h" 

using namespace rapidjson;

#include "common.h"

void TryAllocateBuffer(mwSize bufferLength, char*& filename);
void TryGetFilenameString(const mxArray* prhs[], char*& filename, mwSize bufferLength);
void ReadFile(const char* filename, char*& fileContents, size_t& length);

void ValidateArguments(int nlhs, int nrhs, const mxArray* prhs[], const char* module)
{
    if (nrhs == 0)
    {
        throw "Missing filename argument.";
    }

    if (nrhs > 1)
    {
        mexWarnMsgTxt("jsParseJson: Ignoring extra input arguments.\n");
    }

    // mxGetM, get the number of rows of mxArray
    if (!mxIsChar(prhs[0]) || (mxGetM(prhs[0]) != 1 ))
    {
        char msg[1000];
        sprintf(msg, "Usage: %s(filename)", module);
        throw msg;
    }
}

void GetFilenameFromArguments(const mxArray* prhs[], char*& filename)
{
    mwSize bufferLength = (mwSize)(mxGetN(prhs[0])*sizeof(mxChar) + 1);
    TryAllocateBuffer(bufferLength, filename);
    TryGetFilenameString(prhs, filename, bufferLength);
}

void TryAllocateBuffer(mwSize bufferLength, char*& filename)
{
    filename = (char*)mxMalloc(bufferLength);
    if (!filename)
    {
        throw "Couldn't allocate space to store filename.";
    }
}

void TryGetFilenameString(const mxArray* prhs[], char*& filename, mwSize bufferLength)
{
    if (mxGetString(prhs[0], filename, bufferLength) != 0)
    {
        throw "Couldn't retrieve filename string from input arguments.";
    }
}

void ReadParseJsonFile(const char* filename, Document& document)
{
    size_t len = 0;
    char* jsonStr = nullptr;

    ReadFile(filename, jsonStr, len);

    if (document.Parse<0>((const char*)jsonStr).HasParseError())
    {
        MXFREE(jsonStr);
        static char msg[1000];
        sprintf(msg, "Parse file, %s, error: (%u):%s", filename, (unsigned)document.GetErrorOffset(), document.GetParseError());
        throw msg;
    }

    MXFREE(jsonStr);
}

void ReadFile(const char* filename, char*& fileContents, size_t& length)
{
    FILE *fp = fopen(filename, "rb");

    if (fp)
    {
        fseek(fp, 0, SEEK_END);
        length = (size_t)ftell(fp);
        fseek(fp, 0, SEEK_SET);

        TryAllocateBuffer((mwSize)(length + 1), fileContents);

        fread(fileContents, 1, length, fp);
        fileContents[length] = '\0';

        fclose(fp);
    }
    else
    {
        static char msg[1000];
        sprintf(msg, "Couldn't open JSON file '%s'.", filename);
        throw msg;
    }
}
