let  
    content_type = "application/json", 
    post_data = (verbatim as text, max_tokens as number, temperature as number, customer as text, product as text) =>  
        let 
            temperatureTXT = Replacer.ReplaceText(Text.From(temperature), ",", "."),
            contextUser = "{customer : " & Text.From(customer) & "product : " & Text.From(product) & "}",
            answerSystemMessage = Answer_prompt & " Follow these instructions: "& Answer_instructions &". Finally, start your answer by greeting the customers by their name and mention the purchased product, these informations are in the the following dictionary: "& contextUser,
            answerJSON = "{""messages"" : [
                        {""role"":""system"",""content"":""" & answerSystemMessage & """},
                        {""role"":""user"",""content"":""" & Replacer.ReplaceText(Replacer.ReplaceText(verbatim, "#(lf)", " "), """", "'") & """}
                        ]
                    , ""max_tokens"":" & Text.From(max_tokens) & ", ""temperature"":" & temperatureTXT & 
                    "}",
            post_request = Web.Contents(  
                "https://" & api_base & ".openai.azure.com/openai/deployments/gpt432k/chat/completions?api-version=" & api_version & "&Content-Type=" & content_type & "&api-key=" & api_key,  
                [  
                    Headers = [#"Content-Type"=content_type],  
                    Content = Text.ToBinary(answerJSON),  
                    ManualStatusHandling={400..499, 500..599}
                ]  
            ),  
            answerResponse = if (Value.Metadata(post_request)[Response.Status] = 200) then Json.Document(post_request) else null
            , choices = answerResponse[choices]
            , choices1 = choices{0}
            , message = choices1[message]
            , content = message[content]
        in content
in
    post_data
    
