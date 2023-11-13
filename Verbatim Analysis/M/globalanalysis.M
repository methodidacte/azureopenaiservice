let  
    content_type = "application/json", 
    post_data = (verbatim as text, max_tokens as number, temperature as number) =>  
        let 
            temperatureTXT = Replacer.ReplaceText(Text.From(temperature), ",", "."),
            systemMessage = Summary_prompt ,
            json = "{""messages"" : [
                        {""role"":""system"",""content"":""" & systemMessage & """},
                        {""role"":""user"",""content"":""" & Replacer.ReplaceText(Replacer.ReplaceText(verbatim, "#(lf)", " "), """", "'") & """}
                        ]
                    , ""max_tokens"":" & Text.From(max_tokens) & ", ""temperature"":" & temperatureTXT & 
                    "}",
            post_request = Web.Contents(  
                "https://" & api_base & ".openai.azure.com/openai/deployments/gpt432k/chat/completions?api-version=" & api_version & "&Content-Type=" & content_type & "&api-key=" & api_key,  
                [  
                    Headers = [#"Content-Type"=content_type],  
                    Content = Text.ToBinary(json),  
                    ManualStatusHandling={400..499, 500..599}  
                ]  
            ),  
            response = if (Value.Metadata(post_request)[Response.Status] = 200) then Json.Document(post_request) else null
            , choices = response[choices]
            , choices1 = choices{0}
            , message = choices1[message]
            , content = message[content]
        in content
in
    post_data
    
