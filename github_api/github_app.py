# import libraries
import json
import requests
import pandas as pd
import chart_studio.plotly as py
import plotly.graph_objects as go

# query github api
languages = requests.get("https://api.github.com/repos/jolene-lim/personal_projects/languages")

# error handling
if languages.status_code != 200:
    print("The response returned an error. Status code: " + languages.status_code)

# else parse JSON to dataframe
else:
    languages = pd.DataFrame.from_dict(languages.json(), orient = 'index', columns = ['n_byte'])
    languages = languages.drop('HTML')

# visualize plots
labels = list(languages.index)
values = languages['n_byte'].tolist()

## create colour scheme according to github
langColors = requests.get("https://raw.githubusercontent.com/Diastro/github-colors/master/github-colors.json").json()

colors = []
for lang in labels:
    colors.append(langColors[lang])

## plot
fig = go.Figure(go.Pie(labels = labels, values = values,
             hole = 0.3, marker_colors = colors))

fig.update_layout(
    title = {
        'text': "Programming Languages Used (Bytes)",
        'y': 0.9,
        'x': 0.5,
        'xanchor': 'center',
        'yanchor': 'top'
    }
)
py.plot(fig, filename = 'github-languages', sharing = 'public')