import ballerina/http;
import ballerina/log;

service /text\-processing on new http:Listener(9099) {
    //log
    public function init() {
        log:printInfo("sentiment analysis service stared....");

    }

    resource function post api/sentiment(@http:Payload Post post) returns Sentiment {
        return  {
            "probability": { 
                "neg": 0.30135019761690551, 
                "neutral": 0.27119050546800266, 
                "pos": 0.69864980238309449
            }, 
            "label": "pos"
        };

    }
}

type Sentiment record {
    Probability probability;
    string label;
};

type Post record {
    string text;
};

type Probability record {
    decimal neg;
    decimal neutral;
    decimal pos;
};
